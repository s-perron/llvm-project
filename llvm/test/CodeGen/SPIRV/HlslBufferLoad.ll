; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv-vulkan-compute %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv-vulkan-compute %s -o - -filetype=obj | spirv-val %}

; CHECK: OpDecorate [[var:%[0-9]+]] DescriptorSet 16
; CHECK: OpDecorate [[var]] Binding 7

; CHECK: [[float:%[0-9]+]] = OpTypeFloat 32
; CHECK: [[uint:%[0-9]+]] = OpTypeInt 32 0
; CHECK: [[v4float:%[0-9]+]] = OpTypeVector [[float]] 4
; CHECK: [[uint_0:%[0-9]+]] = OpConstant [[uint]] 0

; CHECK: [[ImageType:%[0-9]+]] = OpTypeImage [[float]] Buffer 2 0 0 2 R32i {{$}}
; CHECK: [[PtrType:%[0-9]+]] = OpTypePointer UniformConstant [[ImageType]]
; CHECK: [[var]] = OpVariable [[PtrType]] UniformConstant 

; CHECK: {{%[0-9]+}} = OpFunction {{%[0-9]+}} None {{%[0-9]+}}              ; -- Begin function UseReadImage
; CHECK-NEXT: OpLabel
define void @UseReadImage() {

; CHECK-NEXT: [[buffer:%[0-9]+]] = OpLoad [[ImageType]] [[var]]
  %buffer = call target("spirv.Image", float, 5, 2, 0, 0, 2, 24)
      @llvm.spv.image.fromBinding.tspirv.Image_f32_5_2_0_0_2_24(
          i32 16, i32 7, i32 1, i32 0, i1 false)

  ; NOTE 1: We cannot use the "read_image*" functions from OpenCL because HLSL
  ;         source could define that function differently.
; CHECK-NEXT: OpImageRead [[v4float]] [[buffer]] [[uint_0]]
  %data0 = call <4 x float> @__spirv_ImageRead(
    target("spirv.Image", float, 5, 2, 0, 0, 2, 24) %buffer, i32 0)

  ret void
}

declare spir_func <4 x float> @__spirv_ImageRead(target("spirv.Image", float, 5, 2, 0, 0, 2, 24) %0, i32 %1)
