; RUN: llc -O0 -verify-machineinstrs -mtriple=spirv1.6-vulkan1.3-library %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv1.6-vulkan1.3-library %s -o - -filetype=obj | spirv-val %}

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64-G1"
%struct.S = type { [10 x i32] }

@private = internal addrspace(10) global %struct.S poison
@storage_buffer = internal addrspace(11) global %struct.S poison

; CHECK: STEVEN

define %struct.S @private_load() #1 {
entry:
  %1 = load %struct.S, ptr addrspace(10) @private, align 4
  ret %struct.S %1
}

define %struct.S @storage_buffer_load() #1 {
entry:
  %1 = load %struct.S, ptr addrspace(11) @storage_buffer, align 4
  ret %struct.S %1
}

define %struct.S @vulkan_buffer_load() #1 {
entry:
  %handle = tail call target("spirv.VulkanBuffer", [0 x %struct.S], 12, 0) @llvm.spv.resource.handlefrombinding(i32 0, i32 0, i32 1, i32 0, i1 false)
  %0 = tail call noundef nonnull align 4 dereferenceable(4) ptr addrspace(11) @llvm.spv.resource.getpointer(target("spirv.VulkanBuffer", [0 x %struct.S], 12, 0) %handle, i32 1)
  %1 = load %struct.S, ptr addrspace(11) %0, align 4
  ret %struct.S %1
}

attributes #1 = { convergent noinline norecurse "approx-func-fp-math"="true" "frame-pointer"="all" "hlsl.numthreads"="1,1,1" "hlsl.shader"="compute" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-
size"="8" }

