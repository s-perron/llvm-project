// RUN: %clang_cc1 -triple dxil-pc-shadermodel6.0-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | FileCheck %s --check-prefixes=CHECK,DXIL
// RUN: %clang_cc1 -triple spirv-vulkan-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | FileCheck %s --check-prefixes=CHECK,SPIRV

Texture2D<float4> t;
SamplerState s;

// CHECK-LABEL: @_Z10test_clampDv2_fS_S_
// CHECK: %[[CALL_CLAMP:.*]] = call reassoc nnan ninf nsz arcp afn noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE10SampleGradENS_12SamplerStateEDv2_fS4_S4_Dv2_if(ptr {{.*}} @_ZL1t, ptr {{.*}} byval(%"class.hlsl::SamplerState") {{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x i32> noundef <i32 1, i32 2>, float {{.*}} 1.000000e+00)
// CHECK: ret <4 x float> %[[CALL_CLAMP]]

float4 test_clamp(float2 loc : LOC, float2 ddx : DDX, float2 ddy : DDY) : SV_Target {
  return t.SampleGrad(s, loc, ddx, ddy, int2(1, 2), 1.0f);
}

// CHECK-LABEL: define linkonce_odr hidden noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE10SampleGradENS_12SamplerStateEDv2_fS4_S4_Dv2_if(
// CHECK: %[[HANDLE3:[^ ]+]] = load target{{.*}}, ptr %{{.*}}
// CHECK: %[[SAMPLER_H3:[^ ]+]] = load target{{.*}}, ptr %{{.*}}
// CHECK: %[[CLAMP_CAST3:[^ ]+]] = fptrunc {{.*}} double {{.*}} to float
// DXIL: call {{.*}} <4 x float> @llvm.dx.resource.samplegrad.clamp.v4f32.tdx.Texture_v4f32_0_0_0_2t.tdx.Sampler_0t.v2f32.v2f32.v2f32.v2i32(target("dx.Texture", <4 x float>, 0, 0, 0, 2) %[[HANDLE3]], target("dx.Sampler", 0) %[[SAMPLER_H3]], <2 x float> %{{.*}}, <2 x float> %{{.*}}, <2 x float> %{{.*}}, <2 x i32> %{{.*}}, float %[[CLAMP_CAST3]])
// SPIRV: call {{.*}} <4 x float> @llvm.spv.resource.samplegrad.clamp.v4f32.tspirv.Image_f32_1_2_0_0_1_0t.tspirv.Samplert.v2f32.v2f32.v2f32.v2i32(target("spirv.Image", float, 1, 2, 0, 0, 1, 0) %[[HANDLE3]], target("spirv.Sampler") %[[SAMPLER_H3]], <2 x float> %{{.*}}, <2 x float> %{{.*}}, <2 x float> %{{.*}}, <2 x i32> %{{.*}}, float %[[CLAMP_CAST3]])
