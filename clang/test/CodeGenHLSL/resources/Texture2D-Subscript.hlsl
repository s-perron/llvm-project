// RUN: %clang_cc1 -triple dxil-pc-shadermodel6.0-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -Wno-sign-conversion -o - %s | llvm-cxxfilt | FileCheck %s --check-prefixes=CHECK,DXIL
// RUN: %clang_cc1 -triple spirv-vulkan-library -x hlsl -emit-llvm -disable-llvm-passes -finclude-default-header -Wno-sign-conversion -o - %s | llvm-cxxfilt | FileCheck %s --check-prefixes=CHECK,SPIRV

Texture2D<float4> Tex : register(t0);

[numthreads(1,1,1)]
void main(uint2 DTid : SV_DispatchThreadID) {
  float4 val = Tex[DTid];
}

// CHECK: define hidden {{.*}}void @main(unsigned int vector[2])(<2 x i32> noundef %[[DTID:.*]])
// CHECK: %[[DTID_ADDR:.*]] = alloca <2 x i32>, align 8
// CHECK: %[[VAL:.*]] = alloca <4 x float>, align 16
// CHECK: store <2 x i32> %[[DTID]], ptr %[[DTID_ADDR]], align 8
// CHECK: %[[DTID_VAL:.*]] = load <2 x i32>, ptr %[[DTID_ADDR]], align 8
// CHECK: %[[CALL1:.*]] = call noundef {{.*}}ptr{{.*}} @hlsl::Texture2D<float vector[4]>::operator[](unsigned int vector[2]) const(ptr noundef nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) @Tex, <2 x i32> noundef %[[DTID_VAL]])
// CHECK: %[[LOAD_VAL:.*]] = load <4 x float>, ptr{{.*}} %[[CALL1]], align 16
// CHECK: store <4 x float> %[[LOAD_VAL]], ptr %[[VAL]], align 16

// CHECK: define linkonce_odr hidden noundef {{.*}}ptr{{.*}} @hlsl::Texture2D<float vector[4]>::operator[](unsigned int vector[2]) const(ptr noundef nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) %[[THIS:.*]], <2 x i32> noundef %[[INDEX:.*]])
// CHECK: %[[THIS_ADDR:.*]] = alloca ptr, align {{.*}}
// CHECK: %[[INDEX_ADDR:.*]] = alloca <2 x i32>, align 8
// CHECK: store ptr %[[THIS]], ptr %[[THIS_ADDR]], align {{.*}}
// CHECK: store <2 x i32> %[[INDEX]], ptr %[[INDEX_ADDR]], align 8
// CHECK: %[[THIS1:.*]] = load ptr, ptr %[[THIS_ADDR]], align {{.*}}
// CHECK: %[[HANDLE_PTR:.*]] = getelementptr {{.*}} %"class.hlsl::Texture2D", ptr %[[THIS1]], i32 0, i32 0
// DXIL: %[[HANDLE:.*]] = load target("dx.Texture", <4 x float>, 0, 0, 0, 2), ptr %[[HANDLE_PTR]], align 4
// SPIRV: %[[HANDLE:.*]] = load target("spirv.Image", float, 1, 2, 0, 0, 1, 0), ptr %[[HANDLE_PTR]], align 8
// CHECK: %[[INDEX_VAL:.*]] = load <2 x i32>, ptr %[[INDEX_ADDR]], align 8
// DXIL: %[[PTR:.*]] = call ptr @llvm.dx.resource.getpointer.p0.tdx.Texture_v4f32_0_0_0_2t.v2i32(target("dx.Texture", <4 x float>, 0, 0, 0, 2) %[[HANDLE]], <2 x i32> %[[INDEX_VAL]])
// SPIRV: %[[PTR:.*]] = call ptr addrspace(11) @llvm.spv.resource.getpointer.p11.tspirv.Image_f32_1_2_0_0_1_0t.v2i32(target("spirv.Image", float, 1, 2, 0, 0, 1, 0) %[[HANDLE]], <2 x i32> %[[INDEX_VAL]])
// CHECK: ret ptr {{.*}}%[[PTR]]
