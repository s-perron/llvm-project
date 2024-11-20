// RUN: %clang_cc1 -triple spirv-pc-vulkan-compute -emit-llvm -disable-llvm-passes -o - %s | FileCheck %s --enable-var-scope

// CHECK: declare spir_func noundef i64 @_Z9ReadClockj(i32 noundef) #[[#ClockAttr:]]
[[vk::ext_instruction(/* OpReadClockKHR */ 5056)]]
long ReadClock(unsigned int scope);

// CHECK: declare spir_func noundef float @_Z7spv_sinf(float noundef) #[[#SinAttr:]]
[[vk::ext_instruction(/* Sin*/ 13, "GLSL.std.450")]]
float spv_sin(float v);

// CHECK: declare spir_func noundef i32 @_Z8GroupAddiij(i32 noundef, i32 noundef "spv.literal", i32 noundef) #[[#AddAttr:]]
[[vk::ext_instruction( /* OpGroupIAdd */ 264 )]]
unsigned int GroupAdd(int scope, [[vk::ext_literal]] int GroupOperation, unsigned int value);


// TODO: Need to test with different address spaces if HLSL starts using more address spaces.
// CHECK: declare spir_func noundef i32 @_Z9AtomicXorRiiii(ptr noundef nonnull align 4 dereferenceable(4), i32 noundef, i32 noundef, i32 noundef) #[[#AtomicAttr:]]
[[vk::ext_instruction( /* OpAtomicXor */ 242 )]]
int AtomicXor([[vk::ext_reference]] int Pointer, int Scope, int MemorySemantics, int value);

[numthreads(1,1,1)]
void main() {
  long clock = ReadClock(1);
  float f = spv_sin(0.0);
  int i = GroupAdd( /* Workgroup */ 2, /* Reduced */ 0, 10 );
  i = AtomicXor( i, /*Workgroup*/ 2, /* AcquireRelease */ 8, 0xF );
}

// CHECK: attributes #[[#ClockAttr]] = { convergent "no-trapping-math"="true" "spv.ext_instruction"="5056," "stack-protector-buffer-size"="8" }
// CHECK: attributes #[[#SinAttr]] = { convergent "no-trapping-math"="true" "spv.ext_instruction"="13,GLSL.std.450" "stack-protector-buffer-size"="8" }
// CHECK: attributes #[[#AddAttr]] = { convergent "no-trapping-math"="true" "spv.ext_instruction"="264," "stack-protector-buffer-size"="8" }
// CHECK: attributes #[[#AtomicAttr]] = { convergent "no-trapping-math"="true" "spv.ext_instruction"="242," "stack-protector-buffer-size"="8" }