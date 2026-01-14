// RUN: %clang_cc1 -triple dxil-pc-shadermodel6.0-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | FileCheck %s --check-prefixes=CHECK,DXIL
// RUN: %clang_cc1 -triple spirv-vulkan-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | FileCheck %s --check-prefixes=CHECK,SPIRV

// DXIL: %"class.hlsl::Texture2D" = type { target("dx.Texture", <4 x float>, 0, 0, 0, 2) }
// DXIL: %"class.hlsl::SamplerState" = type { target("dx.Sampler", 0) }

// SPIRV: %"class.hlsl::Texture2D" = type { target("spirv.Image", float, 1, 2, 0, 0, 1, 0) }
// SPIRV: %"class.hlsl::SamplerState" = type { target("spirv.Sampler") }

Texture2D<float4> t;
SamplerState s;

// CHECK: define hidden {{.*}} <4 x float> @_Z4mainDv2_f(<2 x float> noundef nofpclass(nan inf) %[[LOC:.*]])
// CHECK: %[[CALL:.*]] = call reassoc nnan ninf nsz arcp afn noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE6SampleENS_12SamplerStateEDv2_f(ptr noundef nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) @_ZL1t, ptr noundef byval(%"class.hlsl::SamplerState") align {{[0-9]+}} %{{.*}}, <2 x float> noundef nofpclass(nan inf) %{{.*}})
// CHECK: ret <4 x float> %[[CALL]]

float4 main(float2 loc : LOC) : SV_Target {
  return t.Sample(s, loc);
}

// CHECK: define linkonce_odr {{.*}} noundef nofpclass(nan inf) <4 x float> @_ZN4hlsl9Texture2DIDv4_fE6SampleENS_12SamplerStateEDv2_f(ptr noundef nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) %[[THIS:.*]], ptr noundef byval(%"class.hlsl::SamplerState") align {{[0-9]+}} %[[SAMPLER:.*]], <2 x float> noundef nofpclass(nan inf) %[[COORD:.*]])
// CHECK-NEXT: entry:
// CHECK: %[[THIS_ADDR:.*]] = alloca ptr
// CHECK-NEXT: %[[COORD_ADDR:.*]] = alloca <2 x float>
// CHECK-NEXT: store ptr %[[THIS]], ptr %[[THIS_ADDR]]
// CHECK-NEXT: store <2 x float> %[[COORD]], ptr %[[COORD_ADDR]]
// CHECK-NEXT: %[[THIS1:.*]] = load ptr, ptr %[[THIS_ADDR]]
// CHECK-NEXT: %[[H_ATTR:.*]] = getelementptr inbounds {{.*}}%"class.hlsl::Texture2D", ptr %[[THIS1]], i32 0, i32 0
// CHECK-NEXT: %[[HANDLE:.*]] = load target
// DXIL-SAME: ("dx.Texture", <4 x float>, 0, 0, 0, 2), ptr %[[H_ATTR]]
// SPIRV-SAME: ("spirv.Image", float, 1, 2, 0, 0, 1, 0), ptr %[[H_ATTR]]
// CHECK-NEXT: %[[S_ATTR:.*]] = getelementptr inbounds {{.*}}%"class.hlsl::SamplerState", ptr %[[SAMPLER]], i32 0, i32 0
// CHECK-NEXT: %[[SAMPLER_H:.*]] = load target
// DXIL-SAME: ("dx.Sampler", 0), ptr %[[S_ATTR]]
// SPIRV-SAME: ("spirv.Sampler"), ptr %[[S_ATTR]]
// CHECK-NEXT: %[[COORD_VAL:.*]] = load <2 x float>, ptr %[[COORD_ADDR]]
// DXIL-NEXT: %[[RES:.*]] = call {{.*}} <4 x float> @llvm.dx.resource.sample.v4f32.tdx.Texture_v4f32_0_0_0_2t.tdx.Sampler_0t.v2f32(target("dx.Texture", <4 x float>, 0, 0, 0, 2) %[[HANDLE]], target("dx.Sampler", 0) %[[SAMPLER_H]], <2 x float> %[[COORD_VAL]])
// SPIRV-NEXT: %[[RES:.*]] = call {{.*}} <4 x float> @llvm.spv.resource.sample.v4f32.tspirv.Image_f32_1_2_0_0_1_0t.tspirv.Samplert.v2f32(target("spirv.Image", float, 1, 2, 0, 0, 1, 0) %[[HANDLE]], target("spirv.Sampler") %[[SAMPLER_H]], <2 x float> %[[COORD_VAL]])
// CHECK-NEXT: ret <4 x float> %[[RES]]