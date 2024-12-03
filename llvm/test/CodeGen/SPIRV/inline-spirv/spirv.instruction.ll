; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv-vulkan-compute %s -o - | FileCheck %s

; The ReadClock function requires a capability to be added to pass validation.
; This will be added by another feature in another commit. Disabling for now.
; RUN-DISABLE: %if spirv-tools %{ llc -O0 -mtriple=spirv-vulkan-compute %s -o - -filetype=obj | spirv-val %}

; CHECK-DAG: %[[#uint:]] = OpTypeInt 32 0
; CHECK-DAG: %[[#ulong:]] = OpTypeInt 64 0
; CHECK-DAG: %[[#uint_1:]] = OpConstant %[[#uint]] 1

; Function Attrs: alwaysinline convergent mustprogress norecurse nounwind
define internal spir_func void @_Z4mainv() #0 {
entry:
  %0 = call token @llvm.experimental.convergence.entry()
  %clock = alloca i64, align 8
  %f = alloca float, align 4
; CHECK: !5056 %[[#ulong]] %[[#uint_1]]
  %call1 = call spir_func noundef i64 @_Z9ReadClockj(i32 noundef 1) #5 [ "convergencectrl"(token %0) ]
  store i64 %call1, ptr %clock, align 8
  %call2 = call spir_func noundef float @_Z7spv_sinf(float noundef 0.000000e+00) #5 [ "convergencectrl"(token %0) ]
  store float %call2, ptr %f, align 4
  ret void
}

; Function Attrs: convergent noinline norecurse
define void @main() #1 {
entry:
  %0 = call token @llvm.experimental.convergence.entry()
  call spir_func void @_Z4mainv() [ "convergencectrl"(token %0) ]
  ret void
}

; Function Attrs: convergent nocallback nofree nosync nounwind willreturn memory(none)
declare token @llvm.experimental.convergence.entry() #2

; Function Attrs: convergent
declare spir_func noundef i64 @_Z9ReadClockj(i32 noundef) #3

; Function Attrs: convergent
declare spir_func noundef float @_Z7spv_sinf(float noundef) #4

attributes #0 = { alwaysinline convergent mustprogress norecurse nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { convergent noinline norecurse "hlsl.numthreads"="1,1,1" "hlsl.shader"="compute" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #2 = { convergent nocallback nofree nosync nounwind willreturn memory(none) }
attributes #3 = { convergent "no-trapping-math"="true" "spv.ext_capability"="5055" "spv.ext_extension"="SPV_KHR_shader_clock" "spv.ext_instruction"="5056," "stack-protector-buffer-size"="8" }
attributes #4 = { convergent "no-trapping-math"="true" "spv.ext_instruction"="13,GLSL.std.450" "stack-protector-buffer-size"="8" }
attributes #5 = { convergent }
