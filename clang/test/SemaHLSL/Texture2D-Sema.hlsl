// RUN: %clang_cc1 -triple dxil-pc-shadermodel6.0-library -x hlsl -fsyntax-only -finclude-default-header -verify -verify-ignore-unexpected=note %s

Texture2D<float4> t;
SamplerState s;

void main(float2 loc) {
  t.Sample(s, loc);
  t.Sample(s, loc, int2(1, 2));
  
  // expected-error@+1 {{no matching member function for call to 'Sample'}}
  t.Sample(loc);

  t.Sample(s, loc, int2(1, 2), 1.0);
}
