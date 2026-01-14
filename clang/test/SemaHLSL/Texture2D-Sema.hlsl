// RUN: %clang_cc1 -triple dxil-pc-shadermodel6.0-library -x hlsl -fsyntax-only -finclude-default-header -verify -verify-ignore-unexpected=note %s

Texture2D<float4> t;
SamplerState s;

void main(float2 loc) {
  t.Sample(s, loc);
  
  // expected-error@+1 {{too few arguments to function call, expected 2, have 1}}
  t.Sample(loc);

  // expected-error@+1 {{too many arguments to function call, expected 2, have 3}}
  t.Sample(s, loc, 1.0);
}

