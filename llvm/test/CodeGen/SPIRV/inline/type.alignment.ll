; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv-unknown-unknown %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv-unknown-unknown %s -o - -filetype=obj | spirv-val %}

; CHECK: [[uint_t:%[0-9]+]] = OpTypeInt 32 0
; CHECK: [[uint_ptr_t:%[0-9]+]] = OpTypePointer Function [[uint_t]]

%literal_false = type target("spirv.Literal", 0)
%literal_8 = type target("spirv.Literal", 8)

%type1 = type target("spirv.Type", %literal_8, %literal_false, 21, 1, 8)
%type2 = type target("spirv.Type", %literal_8, %literal_false, 21, 1, 32)
%type3 = type target("spirv.Type", %literal_8, %literal_false, 21, 32, 1)

; TODO: 21 should be hex representation (0x15)
; CHECK: [[type1:%[0-9]+]] = 21 8 0
; CHECK: [[uint_3:%[0-9]+]] = OpConstant [[uint_t]] 3
; CHECK: [[type1_arr:%[0-9]+]] = OpTypeArray [[type1]] [[uint_3]]

; CHECK: [[globals_t:%[0-9]+]] = OpTypeStruct [[type1]] [[type1_arr]] [[type1]] [[type1_arr]] [[type1]] [[type1_arr]] [[uint_t]]
%globals_type = type { %type1, [3 x %type1], %type2, [3 x %type2], %type3, [3 x %type3], i32 }

; CHECK: [[globals_ptr_t:%[0-9]+]] = OpTypePointer Function [[globals_t]]

@globals = external global %globals_type

; TODO: add checks for offset decorations


; TODO: add Int8 capability
define i32 @main() #1 {
entry:
  ; CHECK: [[globals_ptr:%[0-9]+]] = OpVariable [[globals_ptr_t]] Function

  ; TODO: this doesn't seem right – there's no index
  ; CHECK: [[end_ptr:%[0-9]+]] = OpAccessChain [[globals_ptr_t]] [[globals_ptr]]
  %end_ptr = getelementptr %globals_type, ptr @globals, i32 6

  ; CHECK: [[bitcast:%[0-9]+]] = OpBitcast [[uint_ptr_t]] [[end_ptr]]

  ; TODO: can we load this directly as a signed value?
  ; CHECK: {{%[0-9]+}} = OpLoad [[uint_t]] [[bitcast]]
  %end = load i32, ptr %end_ptr
  ret i32 %end
}