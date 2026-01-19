// RUN: %clang_cc1 -triple dxil-pc-shadermodel6.0-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | FileCheck %s --check-prefix=DXIL
// RUN: %clang_cc1 -triple spirv-vulkan-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | FileCheck %s --check-prefix=SPIRV

Texture2D<float4> t;
SamplerState s;

float4 main(float2 loc : LOC, int2 offset : OFFSET) : SV_Target {
  // DXIL: call {{.*}} <4 x float> @llvm.dx.resource.sample.v4f32.tdx.Texture_v4f32_0_0_0_2t.tdx.Sampler_0t.v2f32.v2i32(target("dx.Texture", <4 x float>, 0, 0, 0, 2) %{{.*}}, target("dx.Sampler", 0) %{{.*}}, <2 x float> %{{.*}}, <2 x i32> %{{.*}})
  // SPIRV: call {{.*}} <4 x float> @llvm.spv.resource.sample.v4f32.tspirv.Image_f32_1_2_0_0_1_0t.tspirv.Samplert.v2f32.v2i32(target("spirv.Image", float, 1, 2, 0, 0, 1, 0) %{{.*}}, target("spirv.Sampler") %{{.*}}, <2 x float> %{{.*}}, <2 x i32> %{{.*}})
  return t.Sample(s, loc, offset);
}
