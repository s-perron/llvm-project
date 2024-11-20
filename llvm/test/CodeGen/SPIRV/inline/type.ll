; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv-unknown-unknown %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv-unknown-unknown %s -o - -filetype=obj | spirv-val %}

; TODO: check both LLVM SPIR-V output and spirv-dis output

; CHECK: [[uint8_t:%[0-9]+]] = OpTypeInt 8 0
; CHECK: [[uint8_ptr_t:%[0-9]+]] = OpTypePointer Function [[uint8_t]]

%type_2d_image = type target("spirv.Image", float, 1, 2, 0, 0, 1, 0)

%literal_false = type target("spirv.Literal", 0)
%literal_8 = type target("spirv.Literal", 8)

%integral_constant_4 = type target("spirv.IntegralConstant", i32, 4)

%ArrayTex2D = type target("spirv.Type", %type_2d_image, %integral_constant_4, 28, 0, 0)

; TODO: 21 should be hex representation (0x15)
; CHECK: [[spirvType:%[0-9]+]] = 21 8 0
%uint8_t = type target("spirv.Type", %literal_8, %literal_false, 21, 8, 8)
; CHECK: [[spirvType_ptr:%[0-9]+]] = OpTypePointer Function [[spirvType]]

; TODO: add Int8 capability
define void @main() #1 {
entry:
  ; CHECK: [[uint8_123:%[0-9]+]] = OpConstant [[uint8_t]] 123

  ; CHECK: [[byte:%[0-9]+]] = OpVariable [[spirvType_ptr]] Function
  %byte = alloca %uint8_t

  ; TODO: it probably doesn't make sense to directly store to SpirvType,
  ;       find another way to force usage

  ; CHECK: [[bitcast:%[0-9]+]] = OpBitcast [[uint8_ptr_t]] [[byte]]
  ; CHECK: OpStore [[bitcast]] [[uint8_123]]
  store i8 123, ptr %byte
  ret void
}
