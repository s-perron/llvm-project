; RUN: llc -O0 -verify-machineinstrs -mtriple=spirv1.6-vulkan1.3-library %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv1.6-vulkan1.3-library %s -o - -filetype=obj | spirv-val --target-env vulkan1.3 %}

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64-G10"
target triple = "spirv1.6-unknown-vulkan1.3-compute"

; CHECK-DAG: OpName [[var:%[0-9]+]] "__resource_p_2_{{.*}}_0_1"
; CHECK-DAG: OpName [[cblayout_B:%[0-9]+]] "__cblayout_B"

; CHECK-DAG: OpMemberDecorate [[cblayout_B]] 0 Offset 0
; CHECK-DAG: OpMemberDecorate [[cblayout_B]] 1 Offset 4
; CHECK-DAG: OpMemberDecorate [[block:%[0-9]+]] 0 Offset 0
; CHECK-DAG: OpDecorate [[block]] Block
; CHECK-DAG: OpMemberDecorate [[block]] 0 NonWritable

; CHECK-DAG: [[int:%[0-9]+]] = OpTypeInt 32 0
; CHECK-DAG: [[zero:%[0-9]+]] = OpConstant [[int]] 0
; CHECK-DAG: [[one:%[0-9]+]] = OpConstant [[int]] 1

; CHECK-DAG: [[cblayout_B]] = OpTypeStruct [[int]] [[int]]
; CHECK-DAG: [[block]] = OpTypeStruct [[cblayout_B]]
; CHECK-DAG: [[ptr_type:%[0-9]+]] = OpTypePointer Uniform [[block]]
; CHECK-DAG: [[var]] = OpVariable [[ptr_type]] Uniform

%__cblayout_B = type <{ i32, i32 }>

@B.cb = local_unnamed_addr global target("spirv.VulkanBuffer", target("spirv.Layout", %__cblayout_B, 8, 0, 4), 2, 0) poison
@a = external local_unnamed_addr addrspace(12) global i32, align 4
@b = external local_unnamed_addr addrspace(12) global i32, align 4

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare target("spirv.VulkanBuffer", target("spirv.Layout", %__cblayout_B, 8, 0, 4), 2, 0) @llvm.spv.resource.handlefrombinding.tspirv.VulkanBuffer_tspirv.Layout_s___cblayout_Bs_8_0_4t_2_0t(i32, i32, i32, i32, i1) #0

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(readwrite, argmem: write, inaccessiblemem: none)
define void @main() local_unnamed_addr #1 {
entry:



  %B.cb_h.i.i = tail call target("spirv.VulkanBuffer", target("spirv.Layout", %__cblayout_B, 8, 0, 4), 2, 0) @llvm.spv.resource.handlefrombinding.tspirv.VulkanBuffer_tspirv.Layout_s___cblayout_Bs_8_0_4t_2_0t(i32 0, i32 1, i32 1, i32 0, i1 false)
  store target("spirv.VulkanBuffer", target("spirv.Layout", %__cblayout_B, 8, 0, 4), 2, 0) %B.cb_h.i.i, ptr @B.cb, align 8

  %0 = tail call target("spirv.Image", i32, 5, 2, 0, 0, 2, 0) @llvm.spv.resource.handlefrombinding.tspirv.Image_i32_5_2_0_0_2_0t(i32 0, i32 0, i32 1, i32 0, i1 false)

; CHECK: [[H:%[0-9]+]] = OpCopyObject {{.*}} [[var]]
; CHECK: [[a:%[0-9]+]] = OpAccessChain {{.*}} [[H]] [[zero]] [[zero]]
; CHECK: [[a_val:%[0-9]+]] = OpLoad {{.*}} [[a]] Aligned 4
  %1 = load i32, ptr addrspace(12) @a, align 4, !tbaa !4

; CHECK: [[H:%[0-9]+]] = OpCopyObject {{.*}} [[var]]
; CHECK: [[b:%[0-9]+]] = OpAccessChain {{.*}} [[H]] [[zero]] [[one]]
; CHECK: [[b_val:%[0-9]+]] = OpLoad {{.*}} [[b]] Aligned 4
  %2 = load i32, ptr addrspace(12) @b, align 4, !tbaa !4

; CHECK: OpIAdd {{.*}} [[b_val]] [[a_val]]
  %add.i = add nsw i32 %2, %1
  %3 = tail call noundef align 4 dereferenceable(4) ptr addrspace(11) @llvm.spv.resource.getpointer.p11.tspirv.Image_i32_5_2_0_0_2_0t(target("spirv.Image", i32, 5, 2, 0, 0, 2, 0) %0, i32 0)
  store i32 %add.i, ptr addrspace(11) %3, align 4, !tbaa !4
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare target("spirv.Image", i32, 5, 2, 0, 0, 2, 0) @llvm.spv.resource.handlefrombinding.tspirv.Image_i32_5_2_0_0_2_0t(i32, i32, i32, i32, i1) #0

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare ptr addrspace(11) @llvm.spv.resource.getpointer.p11.tspirv.Image_i32_5_2_0_0_2_0t(target("spirv.Image", i32, 5, 2, 0, 0, 2, 0), i32) #0

attributes #0 = { mustprogress nocallback nofree nosync nounwind willreturn memory(none) }
attributes #1 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(readwrite, argmem: write, inaccessiblemem: none) "approx-func-fp-math"="false" "frame-pointer"="all" "hlsl.numthreads"="1,1,1" "hlsl.shader"="compute" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }

!hlsl.cbs = !{!0}
!llvm.module.flags = !{!1, !2}
!llvm.ident = !{!3}

!0 = !{ptr @B.cb, ptr addrspace(12) @a, ptr addrspace(12) @b}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{!"clang version 21.0.0git (git@github.com:s-perron/llvm-project.git e4f651bf2c78ea605327c5da40f19f730371ceb6)"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
