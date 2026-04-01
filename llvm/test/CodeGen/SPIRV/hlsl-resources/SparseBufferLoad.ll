; RUN: llc -O0 -verify-machineinstrs -mtriple=spirv1.6-unknown-vulkan1.3-compute %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv1.6-unknown-vulkan1.3-compute %s -o - -filetype=obj | spirv-val %}

; CHECK-DAG: OpCapability SparseResidency
; CHECK-DAG: [[TypeInt:%[0-9]+]] = OpTypeInt 32 0
; CHECK-DAG: [[TypeBool:%[0-9]+]] = OpTypeBool
; CHECK-DAG: [[TypeFloat:%[0-9]+]] = OpTypeFloat 32
; CHECK-DAG: [[TypeImage:%[0-9]+]] = OpTypeImage [[TypeFloat]] Buffer 2 0 0 2 Unknown
; CHECK-DAG: [[TypeSparseVecStruct:%[0-9]+]] = OpTypeStruct [[TypeInt]] %[[#]]

; CHECK: [[Handle:%[0-9]+]] = OpLoad [[TypeImage]]
; CHECK: [[SparseResult:%[0-9]+]] = OpImageSparseRead [[TypeSparseVecStruct]] [[Handle]] %[[#]]
; CHECK: [[ResCode:%[0-9]+]] = OpCompositeExtract [[TypeInt]] [[SparseResult]] 0
; CHECK: [[ResVec:%[0-9]+]] = OpCompositeExtract %[[#]] [[SparseResult]] 1
; CHECK: [[ResVal:%[0-9]+]] = OpCompositeExtract [[TypeFloat]] [[ResVec]] 0
; CHECK: [[IsResident:%[0-9]+]] = OpImageSparseTexelsResident [[TypeBool]] [[ResCode]]

define void @main(i32 noundef %idx) {
entry:
  %0 = tail call target("spirv.Image", float, 5, 2, 0, 0, 2, 3) @llvm.spv.resource.handlefromimplicitbinding.tspirv.Image_f32_5_2_0_0_2_3t(i32 0, i32 0, i32 1, i32 0, ptr null)
  %ld.struct = call { i32, float } @llvm.spv.resource.load.typedbuffer.with.status.sl_i32f32s.tspirv.Image_f32_5_2_0_0_2_3t(target("spirv.Image", float, 5, 2, 0, 0, 2, 3) %0, i32 %idx)
  %status = extractvalue { i32, float } %ld.struct, 0
  %val = extractvalue { i32, float } %ld.struct, 1
  %is_mapped = call i1 @llvm.spv.check.access.fully.mapped(i32 %status)
  br i1 %is_mapped, label %if.then, label %if.end

if.then:
  %ptr = call ptr addrspace(11) @llvm.spv.resource.getpointer.p11.tspirv.Image_f32_5_2_0_0_2_3t(target("spirv.Image", float, 5, 2, 0, 0, 2, 3) %0, i32 %idx)
  store float %val, ptr addrspace(11) %ptr, align 4
  br label %if.end

if.end:
  ret void
}

declare target("spirv.Image", float, 5, 2, 0, 0, 2, 3) @llvm.spv.resource.handlefromimplicitbinding.tspirv.Image_f32_5_2_0_0_2_3t(i32, i32, i32, i32, ptr)
declare i1 @llvm.spv.check.access.fully.mapped(i32)
declare { i32, float } @llvm.spv.resource.load.typedbuffer.with.status.sl_i32f32s.tspirv.Image_f32_5_2_0_0_2_3t(target("spirv.Image", float, 5, 2, 0, 0, 2, 3), i32)
declare ptr addrspace(11) @llvm.spv.resource.getpointer.p11.tspirv.Image_f32_5_2_0_0_2_3t(target("spirv.Image", float, 5, 2, 0, 0, 2, 3), i32)
