// RUN: %clang_cc1 -triple spirv-pc-vulkan-compute -emit-llvm -disable-llvm-passes -o - %s | FileCheck %s --enable-var-scope

// CHECK: define void @main() #[[#Attr:]]
[[vk::spvexecutionmode(4446),vk::spvexecutionmode(15)]]
[numthreads(1,1,1)]
void main() {}

// CHECK: attributes #[[#Attr]] = { convergent noinline norecurse "hlsl.numthreads"="1,1,1" "hlsl.shader"="compute" "no-trapping-math"="true" "spv.executionmode"="4446,15" "stack-protector-buffer-size"="8" }