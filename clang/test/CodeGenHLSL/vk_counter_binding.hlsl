// RUN: %clang_cc1 -triple spirv-unknown-unknown -fhlsl-versions=2021 -emit-llvm-only %s -o - | FileCheck %s

// CHECK: call %struct.RWStructuredBuffer.__createFromBindingWithCounter
[[vk::binding(0, 0), vk::counter_binding(1)]]
RWStructuredBuffer<float> g_rw_buffer_explicit;

// CHECK: call %struct.RWStructuredBuffer.__createFromBindingWithImplicitCounter
[[vk::binding(0, 1)]]
RWStructuredBuffer<float> g_rw_buffer_implicit;

// CHECK: call %struct.RWStructuredBuffer.__createFromImplicitBindingWithCounter
[[vk::counter_binding(2)]]
RWStructuredBuffer<float> g_rw_buffer_implicit_main_explicit_counter;

// CHECK: call %struct.RWStructuredBuffer.__createFromImplicitBindingWithImplicitCounter
RWStructuredBuffer<float> g_rw_buffer_implicit_all;
