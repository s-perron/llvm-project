//===- SPIRVCBufferAccess.cpp - Translate CBuffer Loads
//--------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "SPIRVCBufferAccess.h"
#include "SPIRV.h"
#include "llvm/Frontend/HLSL/CBuffer.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include <llvm/IR/IntrinsicsSPIRV.h>

#define DEBUG_TYPE "spirv-cbuffer-access"
using namespace llvm;

static size_t getOffsetForCBufferGEP(GetElementPtrInst *GEP, Type *OriginalTy,
                                     const DataLayout &DL) {
  // Since we should always have a constant offset, we should only ever have a
  // single GEP of indirection from the Global.
  APInt ConstantOffset(DL.getIndexTypeSizeInBits(GEP->getType()), 0);
  bool Success = GEP->accumulateConstantOffset(DL, ConstantOffset);

  // I am following DXILCBufferAccess with this assert. I'm not sure that this
  // will be true.
  (void)Success;
  assert(Success && "Offsets into cbuffer globals must be constant");

  if (auto *ATy = dyn_cast<ArrayType>(OriginalTy))
    ConstantOffset = hlsl::translateCBufArrayOffset(DL, ConstantOffset, ATy);

  return ConstantOffset.getZExtValue();
}

static void convertGEPToIndices(GetElementPtrInst *GEP, Value *OriginalPtr,
                                Type *OriginalTy, Value *ReplacementPtr,
                                Type *ReplacementTy, const DataLayout &DL);

static void applyReplacement(Instruction *Inst, Value *Original,
                             Type *OriginalTy, Value *Replacement,
                             Type *ReplacementTy, const DataLayout &DL) {
  if (auto *GEP = dyn_cast<GetElementPtrInst>(Inst)) {
    convertGEPToIndices(GEP, Original, OriginalTy, Replacement, ReplacementTy,
                        DL);
  }
  Inst->replaceUsesOfWith(Original, Replacement);
}

static void convertGEPToIndices(GetElementPtrInst *GEP, Value *OriginalPtr,
                                Type *OriginalTy, Value *ReplacementPtr,
                                Type *ReplacementTy, const DataLayout &DL) {

  if (OriginalTy == ReplacementTy) return;

  LLVMContext &C = GEP->getContext();
  IRBuilder Builder(GEP);
  Value *NewGEP = nullptr;
  Type* ReplacementElementType = nullptr;

  if (GEP->getSourceElementType() == OriginalTy) {
    SmallVector<Value *> Indices;
    for (uint32_t I = 0; I < GEP->getNumIndices(); ++I) {
      Indices.push_back(GEP->getOperand(I + 1));
    }

    // TODO: Need to use spv_gep instead.
    NewGEP = Builder.CreateGEP(ReplacementTy, ReplacementPtr, Indices);
  } else {
    assert(GEP->getSourceElementType() == Type::getInt8Ty(C));
    APInt ByteOffset;
    [[maybe_unused]] bool Success =
        GEP->accumulateConstantOffset(DL, ByteOffset);
    assert(Success);
    Value *OffsetInBytesValue =
        ConstantInt::get(Type::getInt32Ty(C), ByteOffset.getZExtValue());

    // TODO: Need to use spv_gep instead.
    NewGEP = Builder.CreateGEP(Type::getInt8Ty(C), GEP->getPointerOperand(),
                               {OffsetInBytesValue});
  }

  for(User* U : GEP->users()) {
    applyReplacement(cast<Instruction>(U), GEP, GEP->getResultElementType(), NewGEP, ReplacementElementType, DL);
  }
  return;
}

static Type *getTypeFromGetPointerCall(CallInst *C) {
  assert(C->getCalledFunction()->getIntrinsicID() ==
         Intrinsic::spv_resource_getpointer);
  auto *HandleType = cast<TargetExtType>(C->getOperand(0)->getType());
  assert(HandleType->getTargetExtName() == "spirv.VulkanBuffer");
  Type *Ty = HandleType->getTypeParameter(0);
  TargetExtType *BufferTy = cast<TargetExtType>(Ty);
  assert(BufferTy->getTargetExtName() == "spirv.Layout");
  uint32_t Index = cast<ConstantInt>(C->getOperand(1))->getZExtValue();
  return cast<StructType>(BufferTy->getTypeParameter(0))->getElementType(Index);
}

// Replaces all access to `GV` with a pointer to the `Index`th element of the
// resource pointed to by `HandleGV`.
static void replaceAccessesWithHandle(GlobalVariable *GV,
                                      GlobalVariable *HandleVar,
                                      uint32_t Index) {

  SmallMapVector<Instruction *, CallInst *, 4> Replacements;
  TargetExtType *HandleType = cast<TargetExtType>(HandleVar->getValueType());
  assert(HandleType->getTargetExtName() == "spirv.VulkanBuffer");
  TargetExtType *HandleBaseType =
      cast<TargetExtType>(HandleType->getTypeParameter(0));
  assert(HandleBaseType->getTargetExtName() == "spirv.Layout");

  for (User *U : GV->users()) {
    Instruction *I = dyn_cast<Instruction>(U);
    if (!I)
      continue;
    Module *M = I->getModule();
    IRBuilder Builder(I); // Assuming 'Inst' is the insertion point
    Instruction *Handle = Builder.CreateLoad(HandleType, HandleVar);

    Value *IndexValue =
        ConstantInt::get(IntegerType::get(M->getContext(), 32), Index);
    Intrinsic::ID IntrID = Intrinsic::spv_resource_getpointer;
    SmallVector<Value *> Args = {Handle, IndexValue};
    CallInst *GetPointerCall = Builder.CreateIntrinsic(
        PointerType::get(M->getContext(), GV->getAddressSpace()), IntrID, Args);
    Replacements[I] = GetPointerCall;
  }

  for (auto R : Replacements) {
    Type *ResourceType = getTypeFromGetPointerCall(R.second);
    applyReplacement(R.first, GV, GV->getValueType(), R.second, ResourceType,
                     GV->getDataLayout());
  }
}

static void propagateResourceHandle(GlobalVariable *HandleVar) {
  Value *Handle = HandleVar->getInitializer();

  // HandleVar should have a single store instruction.
  for (auto *User : HandleVar->users()) {
    if (auto *Store = dyn_cast<StoreInst>(User)) {
      Handle = Store->getValueOperand();
      break;
    }
  }

  while (!HandleVar->user_empty()) {
    User *User = HandleVar->user_back();
    auto *L = dyn_cast<LoadInst>(User);
    if (!L) {
      StoreInst *S = cast<StoreInst>(User);
      S->eraseFromParent();
      continue;
    }

    IRBuilder<> Builder(L);
    Value *H = Handle;
    if (Instruction *I = dyn_cast<Instruction>(Handle)) {
      // If the handle is defined by an instruction, clone it so the definition
      // dominates the load.
      auto *C = cast<CallInst>(I);
      assert(C->getCalledFunction()->getIntrinsicID() ==
             Intrinsic::spv_resource_handlefrombinding);

      H = Builder.Insert(I->clone());
    }
    L->replaceAllUsesWith(H);
    L->eraseFromParent();
  }
}

static bool replaceCBufferAccesses(Module &M) {
  dbgs() << "STEVEN: Before replaceCBufferAccesses:\n";
  M.dump();
  std::optional<hlsl::CBufferMetadata> CBufMD = hlsl::CBufferMetadata::get(M);
  if (!CBufMD)
    return false;

  for (const hlsl::CBufferMapping &Mapping : *CBufMD) {
    // Step 1: Replace all uses of the member GlobalVariables with points from
    // the resource handle.
    for (uint32_t Index = 0; Index < Mapping.Members.size(); Index++) {
      replaceAccessesWithHandle(Mapping.Members[Index].GV, Mapping.Handle,
                                Index);
      Mapping.Members[Index].GV->eraseFromParent();
    }

    dbgs() << "STEVEN: Before propagating handle:\n";
    M.dump();
    // Step 2: Replace all references to the variable containing the handle with
    // the handle directly.
    propagateResourceHandle(Mapping.Handle);
    Mapping.Handle->eraseFromParent();
    dbgs() << "STEVEN: After propagating handle:\n";
    M.dump();
  }

  CBufMD->eraseFromModule();
  return true;
}

PreservedAnalyses SPIRVCBufferAccess::run(Module &M,
                                          ModuleAnalysisManager &AM) {
  replaceCBufferAccesses(M);
  return PreservedAnalyses::all();
}

namespace {
class SPIRVCBufferAccessLegacy : public ModulePass {
public:
  bool runOnModule(Module &M) override { return replaceCBufferAccesses(M); }
  StringRef getPassName() const override { return "SPIRV CBuffer Access"; }
  SPIRVCBufferAccessLegacy() : ModulePass(ID) {}

  static char ID; // Pass identification.
};
char SPIRVCBufferAccessLegacy::ID = 0;
} // end anonymous namespace

INITIALIZE_PASS(SPIRVCBufferAccessLegacy, DEBUG_TYPE, "SPIRV CBuffer Access",
                false, false)

ModulePass *llvm::createSPIRVCBufferAccessLegacyPass() {
  return new SPIRVCBufferAccessLegacy();
}
