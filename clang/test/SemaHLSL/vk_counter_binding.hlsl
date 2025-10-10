// RUN: %clang_cc1 -fsyntax-only -verify -fhlsl-versions=2021 %s

[[vk::binding(0, 0), vk::counter_binding(1)]]
RWStructuredBuffer<float> g_rw_buffer;

// expected-error@+1 {{'counter_binding' attribute only applies to resources that have a counter}}
[[vk::binding(0, 1), vk::counter_binding(2)]]
StructuredBuffer<float> g_ro_buffer;

// expected-error@+1 {{'counter_binding' attribute takes exactly one argument}}
[[vk::binding(0, 2), vk::counter_binding(3, 4)]]
RWStructuredBuffer<float> g_rw_buffer2;

// expected-error@+1 {{'counter_binding' attribute requires an integer constant}}
[[vk::binding(0, 3), vk::counter_binding("foo")]]
RWStructuredBuffer<float> g_rw_buffer3;
