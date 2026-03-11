// RUN: %clang_cc1 -triple dxil-pc-shadermodel6.0-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | llvm-cxxfilt | FileCheck %s --check-prefixes=CHECK,DXIL
// RUN: %clang_cc1 -triple spirv-vulkan-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -o - %s | llvm-cxxfilt | FileCheck %s --check-prefixes=CHECK,SPIRV

Texture2D<float4> t;

// CHECK: define hidden {{.*}} <4 x float> @test_load(int vector[2])
// CHECK: %[[COORD:.*]] = insertelement <3 x i32> {{.*}}, i32 0, i32 2
// CHECK: %[[CALL:.*]] = call {{.*}} <4 x float> @hlsl::Texture2D<float vector[4]>::Load(int vector[3])(ptr {{.*}} @t, <3 x i32> noundef %[[COORD]])
// CHECK: ret <4 x float> %[[CALL]]

float4 test_load(int2 loc : LOC) : SV_Target {
  return t.Load(int3(loc, 0));
}

// CHECK: define linkonce_odr hidden {{.*}} <4 x float> @hlsl::Texture2D<float vector[4]>::Load(int vector[3])(ptr {{.*}} %[[THIS:.*]], <3 x i32> {{.*}} %[[LOCATION:.*]])
// CHECK: %[[THIS_ADDR:.*]] = alloca ptr
// CHECK: %[[LOCATION_ADDR:.*]] = alloca <3 x i32>
// CHECK: store ptr %[[THIS]], ptr %[[THIS_ADDR]]
// CHECK: store <3 x i32> %[[LOCATION]], ptr %[[LOCATION_ADDR]]
// CHECK: %[[THIS_VAL:.*]] = load ptr, ptr %[[THIS_ADDR]]
// CHECK: %[[HANDLE_GEP:.*]] = getelementptr inbounds nuw %"class.hlsl::Texture2D", ptr %[[THIS_VAL]], i32 0, i32 0
// CHECK: %[[HANDLE:.*]] = load target("{{(dx.Texture|spirv.Image)}}", {{.*}}), ptr %[[HANDLE_GEP]]
// CHECK: %[[LOCATION_VAL:.*]] = load <3 x i32>, ptr %[[LOCATION_ADDR]]
// CHECK: %[[COORD:.*]] = shufflevector <3 x i32> %[[LOCATION_VAL]], <3 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK: %[[LOD:.*]] = extractelement <3 x i32> %[[LOCATION_VAL]], i64 2
// DXIL: %[[RES:.*]] = call {{.*}} <4 x float> @llvm.dx.resource.load.level.v4f32.tdx.Texture_v4f32_0_0_0_2t.v2i32.i32.v2i32(target("dx.Texture", <4 x float>, 0, 0, 0, 2) %[[HANDLE]], <2 x i32> %[[COORD]], i32 %[[LOD]], <2 x i32> zeroinitializer)
// SPIRV: %[[RES:.*]] = call {{.*}} <4 x float> @llvm.spv.resource.load.level.v4f32.tspirv.Image_f32_1_2_0_0_1_0t.v2i32.i32.v2i32(target("spirv.Image", float, 1, 2, 0, 0, 1, 0) %[[HANDLE]], <2 x i32> %[[COORD]], i32 %[[LOD]], <2 x i32> zeroinitializer)
// CHECK: ret <4 x float> %[[RES]]

// CHECK: define hidden {{.*}} <4 x float> @test_load_offset(int vector[2])
// CHECK: %[[COORD:.*]] = insertelement <3 x i32> {{.*}}, i32 0, i32 2
// CHECK: %[[CALL:.*]] = call {{.*}} <4 x float> @hlsl::Texture2D<float vector[4]>::Load(int vector[3], int vector[2])(ptr {{.*}} @t, <3 x i32> noundef %[[COORD]], <2 x i32> noundef splat (i32 1))
// CHECK: ret <4 x float> %[[CALL]]

float4 test_load_offset(int2 loc : LOC) : SV_Target {
  return t.Load(int3(loc, 0), int2(1, 1));
}

// CHECK: define linkonce_odr hidden noundef {{.*}} <4 x float> @hlsl::Texture2D<float vector[4]>::Load(int vector[3], int vector[2])(ptr {{.*}} %[[THIS:.*]], <3 x i32> {{.*}} %[[LOCATION:.*]], <2 x i32> {{.*}} %[[OFFSET:.*]])
// CHECK: %[[THIS_ADDR:.*]] = alloca ptr
// CHECK: %[[LOCATION_ADDR:.*]] = alloca <3 x i32>
// CHECK: %[[OFFSET_ADDR:.*]] = alloca <2 x i32>
// CHECK: store ptr %[[THIS]], ptr %[[THIS_ADDR]]
// CHECK: store <3 x i32> %[[LOCATION]], ptr %[[LOCATION_ADDR]]
// CHECK: store <2 x i32> %[[OFFSET]], ptr %[[OFFSET_ADDR]]
// CHECK: %[[THIS_VAL:.*]] = load ptr, ptr %[[THIS_ADDR]]
// CHECK: %[[HANDLE_GEP:.*]] = getelementptr inbounds nuw %"class.hlsl::Texture2D", ptr %[[THIS_VAL]], i32 0, i32 0
// CHECK: %[[HANDLE:.*]] = load target("{{(dx.Texture|spirv.Image)}}", {{.*}}), ptr %[[HANDLE_GEP]]
// CHECK: %[[LOCATION_VAL:.*]] = load <3 x i32>, ptr %[[LOCATION_ADDR]]
// CHECK: %[[COORD:.*]] = shufflevector <3 x i32> %[[LOCATION_VAL]], <3 x i32> poison, <2 x i32> <i32 0, i32 1>
// CHECK: %[[LOD:.*]] = extractelement <3 x i32> %[[LOCATION_VAL]], i64 2
// CHECK: %[[OFFSET_VAL:.*]] = load <2 x i32>, ptr %[[OFFSET_ADDR]]
// DXIL: %[[RES:.*]] = call {{.*}} <4 x float> @llvm.dx.resource.load.level.v4f32.tdx.Texture_v4f32_0_0_0_2t.v2i32.i32.v2i32(target("dx.Texture", <4 x float>, 0, 0, 0, 2) %[[HANDLE]], <2 x i32> %[[COORD]], i32 %[[LOD]], <2 x i32> %[[OFFSET_VAL]])
// SPIRV: %[[RES:.*]] = call {{.*}} <4 x float> @llvm.spv.resource.load.level.v4f32.tspirv.Image_f32_1_2_0_0_1_0t.v2i32.i32.v2i32(target("spirv.Image", float, 1, 2, 0, 0, 1, 0) %[[HANDLE]], <2 x i32> %[[COORD]], i32 %[[LOD]], <2 x i32> %[[OFFSET_VAL]])
// CHECK: ret <4 x float> %[[RES]]
