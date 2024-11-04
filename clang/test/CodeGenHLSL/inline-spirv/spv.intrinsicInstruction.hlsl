// RUN: %clang_cc1 -triple spirv-pc-vulkan-compute -emit-llvm -disable-llvm-passes -o - %s | FileCheck %s --enable-var-scope

// CHECK: declare spir_func noundef i64 @_Z9ReadClockj(i32 noundef) #[[#ClockAttr:]]
[[vk::ext_instruction(/* OpReadClockKHR */ 5056)]]
long ReadClock(unsigned int scope);

// CHECK: declare spir_func noundef float @_Z7spv_sinf(float noundef) #[[#SinAttr:]]
[[vk::ext_instruction(/* Sin*/ 13, "GLSL.std.450")]]
float spv_sin(float v);

[numthreads(1,1,1)]
void main() {
  long clock = ReadClock(1);
  float f = spv_sin(0.0);
}

// CHECK: attributes #[[#ClockAttr]] = { convergent "no-trapping-math"="true" "spv.ext_instruction"="5056," "stack-protector-buffer-size"="8" }
// CHECK: attributes #[[#SinAttr]] = { convergent "no-trapping-math"="true" "spv.ext_instruction"="13,GLSL.std.450" "stack-protector-buffer-size"="8" }
