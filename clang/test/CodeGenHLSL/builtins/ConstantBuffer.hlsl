// RUN: %clang_cc1 -finclude-default-header -triple dxil-pc-shadermodel6.0-compute -emit-llvm -disable-llvm-passes -o - %s | FileCheck %s --check-prefixes=CHECK,CHECK-DXIL
// RUN: %clang_cc1 -finclude-default-header -triple spirv-vulkan-library -emit-llvm -disable-llvm-passes -o - %s | FileCheck %s --check-prefixes=CHECK,CHECK-SPIRV

struct S {
  float a;
  int b;
};

// CHECK-DXIL: %"class.hlsl::ConstantBuffer" = type { %struct.S, target("dx.CBuffer", %S) }
// CHECK-SPIRV: %"class.hlsl::ConstantBuffer" = type { %struct.S, target("spirv.VulkanBuffer", %S, 2, 0) }
ConstantBuffer<S> cb;

// CHECK-LABEL: define {{.*}} void @_Z4mainv()
// CHECK-DXIL: [[CB_HANDLE:%.*]] = load target("dx.CBuffer", %S), ptr getelementptr inbounds nuw (i8, ptr @_ZL2cb, i32 8)
// CHECK-DXIL: [[PTR:%.*]] = call ptr addrspace(2) @llvm.dx.resource.getpointer.p2.tdx.CBuffer_s_Sst.i32(target("dx.CBuffer", %S) [[CB_HANDLE]], i32 0)
// CHECK-DXIL: [[GEP_A:%.*]] = getelementptr inbounds nuw %struct.S, ptr addrspace(2) [[PTR]], i32 0, i32 0
// CHECK-DXIL: [[LOAD_A:%.*]] = load float, ptr addrspace(2) [[GEP_A]], align 1

// CHECK-SPIRV: [[CB_HANDLE:%.*]] = load target("spirv.VulkanBuffer", %S, 2, 0), ptr getelementptr inbounds nuw (i8, ptr @_ZL2cb, i64 8)
// CHECK-SPIRV: [[PTR:%.*]] = call ptr addrspace(12) @llvm.spv.resource.getpointer.p12.tspirv.VulkanBuffer_s_Ss_2_0t.i32(target("spirv.VulkanBuffer", %S, 2, 0) [[CB_HANDLE]], i32 0)
// CHECK-SPIRV: [[GEP_A:%.*]] = getelementptr inbounds nuw %struct.S, ptr addrspace(12) [[PTR]], i32 0, i32 0
// CHECK-SPIRV: [[LOAD_A:%.*]] = load float, ptr addrspace(12) [[GEP_A]], align 1

// CHECK: store float [[LOAD_A]], ptr %f, align 4
[numthreads(1,1,1)]
void main() {
  float f = cb.a;
}

struct Nested {
  S s;
  float c;
};

ConstantBuffer<Nested> cb_nested[2];

[numthreads(1,1,1)]
void foo() {
  // CHECK-LABEL: define {{.*}} void @_Z3foov()
  // CHECK-DXIL: [[TMP_CB:%.*]] = alloca %"class.hlsl::ConstantBuffer.0", align 4
  // CHECK-DXIL: call void @_ZN4hlsl14ConstantBufferI6NestedE27__createFromImplicitBindingEjjijPKc(ptr dead_on_unwind writable sret(%"class.hlsl::ConstantBuffer.0") align 4 [[TMP_CB]], i32 noundef 1, i32 noundef 0, i32 noundef 2, i32 noundef 1, ptr noundef @cb_nested.str)
  // CHECK-DXIL: [[HANDLE_PTR:%.*]] = getelementptr inbounds nuw %"class.hlsl::ConstantBuffer.0", ptr [[TMP_CB]], i32 0, i32 1
  // CHECK-DXIL: [[CB_HANDLE_NESTED:%.*]] = load target("dx.CBuffer", %Nested), ptr [[HANDLE_PTR]], align 4
  // CHECK-DXIL: [[PTR_NESTED:%.*]] = call ptr addrspace(2) @llvm.dx.resource.getpointer.p2.tdx.CBuffer_s_Nestedst.i32(target("dx.CBuffer", %Nested) [[CB_HANDLE_NESTED]], i32 0)
  // CHECK-DXIL: [[GEP_S:%.*]] = getelementptr inbounds nuw %struct.Nested, ptr addrspace(2) [[PTR_NESTED]], i32 0, i32 0
  // CHECK-DXIL: [[GEP_A2:%.*]] = getelementptr inbounds nuw %struct.S, ptr addrspace(2) [[GEP_S]], i32 0, i32 0
  // CHECK-DXIL: [[LOAD_A2:%.*]] = load float, ptr addrspace(2) [[GEP_A2]], align 1

  // CHECK-SPIRV: [[TMP_CB:%.*]] = alloca %"class.hlsl::ConstantBuffer.0", align 8
  // CHECK-SPIRV: call void @_ZN4hlsl14ConstantBufferI6NestedE27__createFromImplicitBindingEjjijPKc(ptr dead_on_unwind writable sret(%"class.hlsl::ConstantBuffer.0") align 8 [[TMP_CB]], i32 noundef 1, i32 noundef 0, i32 noundef 2, i32 noundef 1, ptr noundef @cb_nested.str)
  // CHECK-SPIRV: [[HANDLE_PTR:%.*]] = getelementptr inbounds nuw %"class.hlsl::ConstantBuffer.0", ptr [[TMP_CB]], i32 0, i32 1
  // CHECK-SPIRV: [[CB_HANDLE_NESTED:%.*]] = load target("spirv.VulkanBuffer", %Nested, 2, 0), ptr [[HANDLE_PTR]], align 8
  // CHECK-SPIRV: [[PTR_NESTED:%.*]] = call ptr addrspace(12) @llvm.spv.resource.getpointer.p12.tspirv.VulkanBuffer_s_Nesteds_2_0t.i32(target("spirv.VulkanBuffer", %Nested, 2, 0) [[CB_HANDLE_NESTED]], i32 0)
  // CHECK-SPIRV: [[GEP_S:%.*]] = getelementptr inbounds nuw %struct.Nested, ptr addrspace(12) [[PTR_NESTED]], i32 0, i32 0
  // CHECK-SPIRV: [[GEP_A2:%.*]] = getelementptr inbounds nuw %struct.S, ptr addrspace(12) [[GEP_S]], i32 0, i32 0
  // CHECK-SPIRV: [[LOAD_A2:%.*]] = load float, ptr addrspace(12) [[GEP_A2]], align 1

  // CHECK: store float [[LOAD_A2]], ptr %f2, align 4
  float f2 = cb_nested[1].s.a;
}

void takes_s(S s) {}
void takes_cb(ConstantBuffer<S> c) {}

[numthreads(1,1,1)]
void test_assignments_and_params() {
  // CHECK-LABEL: define {{.*}} void @_Z27test_assignments_and_paramsv()
  
  // CHECK-DXIL: [[CB_HANDLE_1:%.*]] = load target("dx.CBuffer", %S), ptr getelementptr inbounds nuw (i8, ptr @_ZL2cb, i32 8), align 4
  // CHECK-DXIL: [[PTR_1:%.*]] = call ptr addrspace(2) @llvm.dx.resource.getpointer.p2.tdx.CBuffer_s_Sst.i32(target("dx.CBuffer", %S) [[CB_HANDLE_1]], i32 0)
  // CHECK-DXIL: call void @llvm.memcpy.p0.p2.i32(ptr align 1 %s, ptr addrspace(2) align 1 [[PTR_1]], i32 8, i1 false)
  // CHECK-SPIRV: [[CB_HANDLE_1:%.*]] = load target("spirv.VulkanBuffer", %S, 2, 0), ptr getelementptr inbounds nuw (i8, ptr @_ZL2cb, i64 8), align 8
  // CHECK-SPIRV: [[PTR_1:%.*]] = call ptr addrspace(12) @llvm.spv.resource.getpointer.p12.tspirv.VulkanBuffer_s_Ss_2_0t.i32(target("spirv.VulkanBuffer", %S, 2, 0) [[CB_HANDLE_1]], i32 0)
  // CHECK-SPIRV: call void @llvm.memcpy.p0.p12.i64(ptr align 1 %s, ptr addrspace(12) align 1 [[PTR_1]], i64 8, i1 false)
  S s = cb;

  // CHECK-DXIL: [[CB_HANDLE_2:%.*]] = load target("dx.CBuffer", %S), ptr getelementptr inbounds nuw (i8, ptr @_ZL2cb, i32 8), align 4
  // CHECK-DXIL: [[PTR_2:%.*]] = call ptr addrspace(2) @llvm.dx.resource.getpointer.p2.tdx.CBuffer_s_Sst.i32(target("dx.CBuffer", %S) [[CB_HANDLE_2]], i32 0)
  // CHECK-DXIL: call void @llvm.memcpy.p0.p2.i32(ptr align 1 %s, ptr addrspace(2) align 1 [[PTR_2]], i32 8, i1 false)
  // CHECK-SPIRV: [[CB_HANDLE_2:%.*]] = load target("spirv.VulkanBuffer", %S, 2, 0), ptr getelementptr inbounds nuw (i8, ptr @_ZL2cb, i64 8), align 8
  // CHECK-SPIRV: [[PTR_2:%.*]] = call ptr addrspace(12) @llvm.spv.resource.getpointer.p12.tspirv.VulkanBuffer_s_Ss_2_0t.i32(target("spirv.VulkanBuffer", %S, 2, 0) [[CB_HANDLE_2]], i32 0)
  // CHECK-SPIRV: call void @llvm.memcpy.p0.p12.i64(ptr align 1 %s, ptr addrspace(12) align 1 [[PTR_2]], i64 8, i1 false)
  s = cb;

  // CHECK-DXIL: [[CB_HANDLE_3:%.*]] = load target("dx.CBuffer", %S), ptr getelementptr inbounds nuw (i8, ptr @_ZL2cb, i32 8), align 4
  // CHECK-DXIL: [[PTR_3:%.*]] = call ptr addrspace(2) @llvm.dx.resource.getpointer.p2.tdx.CBuffer_s_Sst.i32(target("dx.CBuffer", %S) [[CB_HANDLE_3]], i32 0)
  // CHECK-DXIL: call void @llvm.memcpy.p0.p2.i32(ptr align 1 %agg.tmp, ptr addrspace(2) align 1 [[PTR_3]], i32 8, i1 false)
  // CHECK-DXIL: call void @_Z7takes_s1S(ptr noundef byval(%struct.S) align 1 %agg.tmp)
  // CHECK-SPIRV: [[CB_HANDLE_3:%.*]] = load target("spirv.VulkanBuffer", %S, 2, 0), ptr getelementptr inbounds nuw (i8, ptr @_ZL2cb, i64 8), align 8
  // CHECK-SPIRV: [[PTR_3:%.*]] = call ptr addrspace(12) @llvm.spv.resource.getpointer.p12.tspirv.VulkanBuffer_s_Ss_2_0t.i32(target("spirv.VulkanBuffer", %S, 2, 0) [[CB_HANDLE_3]], i32 0)
  // CHECK-SPIRV: call void @llvm.memcpy.p0.p12.i64(ptr align 1 %agg.tmp, ptr addrspace(12) align 1 [[PTR_3]], i64 8, i1 false)
  // CHECK-SPIRV: call {{.*}} void @_Z7takes_s1S(ptr noundef byval(%struct.S) align 1 %agg.tmp)
  takes_s(cb);

  // CHECK: call void @_ZN4hlsl14ConstantBufferI1SEC1ERKS2_(ptr noundef nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) %agg.tmp1, ptr noundef nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) @_ZL2cb)
  // CHECK-DXIL: call void @_Z8takes_cbN4hlsl14ConstantBufferI1SEE(ptr noundef dead_on_return %agg.tmp1)
  // CHECK-SPIRV: call {{.*}} void @_Z8takes_cbN4hlsl14ConstantBufferI1SEE(ptr noundef dead_on_return %agg.tmp1)
  takes_cb(cb);
}
