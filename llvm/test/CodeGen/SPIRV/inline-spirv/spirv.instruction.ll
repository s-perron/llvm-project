; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv-vulkan-unknown %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv-vulkan-unknown %s -o - -filetype=obj | spirv-val %}

; CHECK: [[int:%[0-9]+]] = OpTypeInt 32 0
; CHECK-DAG:  [[int4:%[0-9]+]] = OpConstant [[int]] 4
; CHECK-DAG:  [[int3:%[0-9]+]] = OpConstant [[int]] 3

; CHECK: OpFunction
; CHECK-NEXT: OpLabel
define void @main() #0 {
entry:
; CHECK: {{%[0-9]+}} = OpUnknown(128) [[int]] [[int4]] [[int3]]
  %add = call i32
      @llvm.spv.instruction.i32(i32 128, i32 4, i32 3)
; CHECK: OpReturn
  ret void
}

attributes #0 = { convergent noinline norecurse "frame-pointer"="all" "hlsl.numthreads"="1,1,1" "hlsl.shader"="compute" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
