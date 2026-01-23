// RUN: %clang_cc1 -triple dxil-pc-shadermodel6.0-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | FileCheck %s --check-prefixes=CHECK,DXIL
// RUN: %clang_cc1 -triple spirv-vulkan-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | FileCheck %s --check-prefixes=CHECK,SPIRV

// DXIL: %"class.hlsl::Texture2D" = type { target("dx.Texture", <4 x float>, 0, 0, 0, 2) }
// DXIL: %"class.hlsl::SamplerState" = type { target("dx.Sampler", 0) }

// SPIRV: %"class.hlsl::Texture2D" = type { target("spirv.Image", float, 1, 2, 0, 0, 1, 0) }
// SPIRV: %"class.hlsl::SamplerState" = type { target("spirv.Sampler") }

Texture2D<float4> t;
SamplerState s;

// CHECK-LABEL: @_Z9test_gradDv2_fS_S_
// CHECK: %[[CALL:.*]] = call reassoc nnan ninf nsz arcp afn noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE10SampleGradENS_12SamplerStateEDv2_fS4_S4_(ptr {{.*}} @_ZL1t, ptr {{.*}} byval(%"class.hlsl::SamplerState") {{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x float> {{.*}} %{{.*}})
// CHECK: ret <4 x float> %[[CALL]]

float4 test_grad(float2 loc : LOC, float2 ddx : DDX, float2 ddy : DDY) : SV_Target {
  return t.SampleGrad(s, loc, ddx, ddy);
}

// CHECK-LABEL: define linkonce_odr hidden noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE10SampleGradENS_12SamplerStateEDv2_fS4_S4_(
// CHECK-SAME: ptr {{.*}} %[[THIS:[^,]+]], ptr {{.*}} byval(%"class.hlsl::SamplerState") {{.*}} %[[SAMPLER:[^,]+]], <2 x float> {{.*}} %[[COORD:[^,]+]], <2 x float> {{.*}} %[[DDX:[^,]+]], <2 x float> {{.*}} %[[DDY:[^)]+]])
// CHECK: %[[THIS_ADDR:[^ ]+]] = alloca ptr
// CHECK: %[[COORD_ADDR:[^ ]+]] = alloca <2 x float>
// CHECK: %[[DDX_ADDR:[^ ]+]] = alloca <2 x float>
// CHECK: %[[DDY_ADDR:[^ ]+]] = alloca <2 x float>
// CHECK: store ptr %[[THIS]], ptr %[[THIS_ADDR]]
// CHECK: store <2 x float> %[[COORD]], ptr %[[COORD_ADDR]]
// CHECK: store <2 x float> %[[DDX]], ptr %[[DDX_ADDR]]
// CHECK: store <2 x float> %[[DDY]], ptr %[[DDY_ADDR]]
// CHECK: %[[THIS_VAL1:[^ ]+]] = load ptr, ptr %[[THIS_ADDR]]
// CHECK: %[[HANDLE_GEP1:[^ ]+]] = getelementptr inbounds nuw %"class.hlsl::Texture2D", ptr %[[THIS_VAL1]], i32 0, i32 0
// CHECK: %[[HANDLE1:[^ ]+]] = load target{{.*}}, ptr %[[HANDLE_GEP1]]
// CHECK: %[[SAMPLER_GEP1:[^ ]+]] = getelementptr inbounds nuw %"class.hlsl::SamplerState", ptr %[[SAMPLER]], i32 0, i32 0
// CHECK: %[[SAMPLER_H1:[^ ]+]] = load target{{.*}}, ptr %[[SAMPLER_GEP1]]
// CHECK: %[[COORD_VAL:[^ ]+]] = load <2 x float>, ptr %[[COORD_ADDR]]
// CHECK: %[[DDX_VAL:[^ ]+]] = load <2 x float>, ptr %[[DDX_ADDR]]
// CHECK: %[[DDY_VAL:[^ ]+]] = load <2 x float>, ptr %[[DDY_ADDR]]
// DXIL: call {{.*}} <4 x float> @llvm.dx.resource.samplegrad.v4f32.tdx.Texture_v4f32_0_0_0_2t.tdx.Sampler_0t.v2f32.v2f32.v2f32.v2i32(target("dx.Texture", <4 x float>, 0, 0, 0, 2) %[[HANDLE1]], target("dx.Sampler", 0) %[[SAMPLER_H1]], <2 x float> %[[COORD_VAL]], <2 x float> %[[DDX_VAL]], <2 x float> %[[DDY_VAL]], <2 x i32> zeroinitializer)
// SPIRV: call {{.*}} <4 x float> @llvm.spv.resource.samplegrad.v4f32.tspirv.Image_f32_1_2_0_0_1_0t.tspirv.Samplert.v2f32.v2f32.v2f32.v2i32(target("spirv.Image", float, 1, 2, 0, 0, 1, 0) %[[HANDLE1]], target("spirv.Sampler") %[[SAMPLER_H1]], <2 x float> %[[COORD_VAL]], <2 x float> %[[DDX_VAL]], <2 x float> %[[DDY_VAL]], <2 x i32> zeroinitializer)

// CHECK-LABEL: @_Z11test_offsetDv2_fS_S_
// CHECK: %[[CALL_OFFSET:.*]] = call reassoc nnan ninf nsz arcp afn noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE10SampleGradENS_12SamplerStateEDv2_fS4_S4_Dv2_i(ptr {{.*}} @_ZL1t, ptr {{.*}} byval(%"class.hlsl::SamplerState") {{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x i32> noundef <i32 1, i32 2>)
// CHECK: ret <4 x float> %[[CALL_OFFSET]]

float4 test_offset(float2 loc : LOC, float2 ddx : DDX, float2 ddy : DDY) : SV_Target {
  return t.SampleGrad(s, loc, ddx, ddy, int2(1, 2));
}

// CHECK-LABEL: define linkonce_odr hidden noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE10SampleGradENS_12SamplerStateEDv2_fS4_S4_Dv2_i(
// CHECK-SAME: ptr {{.*}} %[[THIS:[^,]+]], ptr {{.*}} byval(%"class.hlsl::SamplerState") {{.*}} %[[SAMPLER:[^,]+]], <2 x float> {{.*}} %[[COORD:[^,]+]], <2 x float> {{.*}} %[[DDX:[^,]+]], <2 x float> {{.*}} %[[DDY:[^,]+]], <2 x i32> {{.*}} %[[OFFSET:[^)]+]])
// CHECK: %[[THIS_ADDR:[^ ]+]] = alloca ptr
// CHECK: %[[COORD_ADDR:[^ ]+]] = alloca <2 x float>
// CHECK: %[[DDX_ADDR:[^ ]+]] = alloca <2 x float>
// CHECK: %[[DDY_ADDR:[^ ]+]] = alloca <2 x float>
// CHECK: %[[OFFSET_ADDR:[^ ]+]] = alloca <2 x i32>
// CHECK: store ptr %[[THIS]], ptr %[[THIS_ADDR]]
// CHECK: store <2 x float> %[[COORD]], ptr %[[COORD_ADDR]]
// CHECK: store <2 x float> %[[DDX]], ptr %[[DDX_ADDR]]
// CHECK: store <2 x float> %[[DDY]], ptr %[[DDY_ADDR]]
// CHECK: store <2 x i32> %[[OFFSET]], ptr %[[OFFSET_ADDR]]
// CHECK: %[[THIS_VAL2:[^ ]+]] = load ptr, ptr %[[THIS_ADDR]]
// CHECK: %[[HANDLE_GEP2:[^ ]+]] = getelementptr inbounds nuw %"class.hlsl::Texture2D", ptr %[[THIS_VAL2]], i32 0, i32 0
// CHECK: %[[HANDLE2:[^ ]+]] = load target{{.*}}, ptr %[[HANDLE_GEP2]]
// CHECK: %[[SAMPLER_GEP2:[^ ]+]] = getelementptr inbounds nuw %"class.hlsl::SamplerState", ptr %[[SAMPLER]], i32 0, i32 0
// CHECK: %[[SAMPLER_H2:[^ ]+]] = load target{{.*}}, ptr %[[SAMPLER_GEP2]]
// CHECK: %[[COORD_VAL:[^ ]+]] = load <2 x float>, ptr %[[COORD_ADDR]]
// CHECK: %[[DDX_VAL:[^ ]+]] = load <2 x float>, ptr %[[DDX_ADDR]]
// CHECK: %[[DDY_VAL:[^ ]+]] = load <2 x float>, ptr %[[DDY_ADDR]]
// CHECK: %[[OFFSET_VAL:[^ ]+]] = load <2 x i32>, ptr %[[OFFSET_ADDR]]
// DXIL: call {{.*}} <4 x float> @llvm.dx.resource.samplegrad.v4f32.tdx.Texture_v4f32_0_0_0_2t.tdx.Sampler_0t.v2f32.v2f32.v2f32.v2i32(target("dx.Texture", <4 x float>, 0, 0, 0, 2) %[[HANDLE2]], target("dx.Sampler", 0) %[[SAMPLER_H2]], <2 x float> %[[COORD_VAL]], <2 x float> %[[DDX_VAL]], <2 x float> %[[DDY_VAL]], <2 x i32> %[[OFFSET_VAL]])
// SPIRV: call {{.*}} <4 x float> @llvm.spv.resource.samplegrad.v4f32.tspirv.Image_f32_1_2_0_0_1_0t.tspirv.Samplert.v2f32.v2f32.v2f32.v2i32(target("spirv.Image", float, 1, 2, 0, 0, 1, 0) %[[HANDLE2]], target("spirv.Sampler") %[[SAMPLER_H2]], <2 x float> %[[COORD_VAL]], <2 x float> %[[DDX_VAL]], <2 x float> %[[DDY_VAL]], <2 x i32> %[[OFFSET_VAL]])

// CHECK-LABEL: @_Z10test_clampDv2_fS_S_
// CHECK: %[[CALL_CLAMP:.*]] = call reassoc nnan ninf nsz arcp afn noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE10SampleGradENS_12SamplerStateEDv2_fS4_S4_Dv2_if(ptr {{.*}} @_ZL1t, ptr {{.*}} byval(%"class.hlsl::SamplerState") {{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x float> {{.*}} %{{.*}}, <2 x i32> noundef <i32 1, i32 2>, float {{.*}} 1.000000e+00)
// CHECK: ret <4 x float> %[[CALL_CLAMP]]

float4 test_clamp(float2 loc : LOC, float2 ddx : DDX, float2 ddy : DDY) : SV_Target {
  return t.SampleGrad(s, loc, ddx, ddy, int2(1, 2), 1.0f);
}

// CHECK-LABEL: define linkonce_odr hidden noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE10SampleGradENS_12SamplerStateEDv2_fS4_S4_Dv2_if(
// CHECK-SAME: ptr {{.*}} %[[THIS:[^,]+]], ptr {{.*}} byval(%"class.hlsl::SamplerState") {{.*}} %[[SAMPLER:[^,]+]], <2 x float> {{.*}} %[[COORD:[^,]+]], <2 x float> {{.*}} %[[DDX:[^,]+]], <2 x float> {{.*}} %[[DDY:[^,]+]], <2 x i32> {{.*}} %[[OFFSET:[^,]+]], float {{.*}} %[[CLAMP:[^)]+]])
// CHECK: %[[THIS_ADDR:[^ ]+]] = alloca ptr
// CHECK: %[[COORD_ADDR:[^ ]+]] = alloca <2 x float>
// CHECK: %[[DDX_ADDR:[^ ]+]] = alloca <2 x float>
// CHECK: %[[DDY_ADDR:[^ ]+]] = alloca <2 x float>
// CHECK: %[[OFFSET_ADDR:[^ ]+]] = alloca <2 x i32>
// CHECK: %[[CLAMP_ADDR:[^ ]+]] = alloca float
// CHECK: store ptr %[[THIS]], ptr %[[THIS_ADDR]]
// CHECK: store <2 x float> %[[COORD]], ptr %[[COORD_ADDR]]
// CHECK: store <2 x float> %[[DDX]], ptr %[[DDX_ADDR]]
// CHECK: store <2 x float> %[[DDY]], ptr %[[DDY_ADDR]]
// CHECK: store <2 x i32> %[[OFFSET]], ptr %[[OFFSET_ADDR]]
// CHECK: store float %[[CLAMP]], ptr %[[CLAMP_ADDR]]
// CHECK: %[[THIS_VAL3:[^ ]+]] = load ptr, ptr %[[THIS_ADDR]]
// CHECK: %[[HANDLE_GEP3:[^ ]+]] = getelementptr inbounds nuw %"class.hlsl::Texture2D", ptr %[[THIS_VAL3]], i32 0, i32 0
// CHECK: %[[HANDLE3:[^ ]+]] = load target{{.*}}, ptr %[[HANDLE_GEP3]]
// CHECK: %[[SAMPLER_GEP3:[^ ]+]] = getelementptr inbounds nuw %"class.hlsl::SamplerState", ptr %[[SAMPLER]], i32 0, i32 0
// CHECK: %[[SAMPLER_H3:[^ ]+]] = load target{{.*}}, ptr %[[SAMPLER_GEP3]]
// CHECK: %[[COORD_VAL:[^ ]+]] = load <2 x float>, ptr %[[COORD_ADDR]]
// CHECK: %[[DDX_VAL:[^ ]+]] = load <2 x float>, ptr %[[DDX_ADDR]]
// CHECK: %[[DDY_VAL:[^ ]+]] = load <2 x float>, ptr %[[DDY_ADDR]]
// CHECK: %[[OFFSET_VAL:[^ ]+]] = load <2 x i32>, ptr %[[OFFSET_ADDR]]
// CHECK: %[[CLAMP_VAL:[^ ]+]] = load float, ptr %[[CLAMP_ADDR]]
// CHECK: %[[CLAMP_CAST3:[^ ]+]] = fptrunc {{.*}} double {{.*}} to float
// DXIL: call {{.*}} <4 x float> @llvm.dx.resource.samplegrad.clamp.v4f32.tdx.Texture_v4f32_0_0_0_2t.tdx.Sampler_0t.v2f32.v2f32.v2f32.v2i32(target("dx.Texture", <4 x float>, 0, 0, 0, 2) %[[HANDLE3]], target("dx.Sampler", 0) %[[SAMPLER_H3]], <2 x float> %[[COORD_VAL]], <2 x float> %[[DDX_VAL]], <2 x float> %[[DDY_VAL]], <2 x i32> %[[OFFSET_VAL]], float %[[CLAMP_CAST3]])
// SPIRV: call {{.*}} <4 x float> @llvm.spv.resource.samplegrad.clamp.v4f32.tspirv.Image_f32_1_2_0_0_1_0t.tspirv.Samplert.v2f32.v2f32.v2f32.v2i32(target("spirv.Image", float, 1, 2, 0, 0, 1, 0) %[[HANDLE3]], target("spirv.Sampler") %[[SAMPLER_H3]], <2 x float> %[[COORD_VAL]], <2 x float> %[[DDX_VAL]], <2 x float> %[[DDY_VAL]], <2 x i32> %[[OFFSET_VAL]], float %[[CLAMP_CAST3]])