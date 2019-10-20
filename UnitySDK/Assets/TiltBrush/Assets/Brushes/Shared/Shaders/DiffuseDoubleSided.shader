// Copyright 2017 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

Shader "Brush/DiffuseDoubleSided" {
Properties {
  _Color ("Main Color", Color) = (1,1,1,1)
  _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
  _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
  _ProximityFade ("Proximity Fade", Range(0,10)) = 10
}

SubShader {
  Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
  LOD 200
  Cull Off

CGPROGRAM
#pragma surface surf Lambert vertex:vert alpha:blend addshadow
#pragma multi_compile __ TBT_LINEAR_TARGET
#include "../../../Shaders/Include/Brush.cginc"
#pragma target 3.0

sampler2D _MainTex;
fixed4 _Color;
half _ProximityFade;
half _Cutoff;

struct Input {
  float2 uv_MainTex;
  float4 color : COLOR;
  fixed vface : VFACE;
  float distance;
};

void vert (inout appdata_full v, out Input o) {
  UNITY_INITIALIZE_OUTPUT(Input,o);
  o.uv_MainTex = v.texcoord;
  o.color = TbVertToNative(v.color);
  o.distance = UnityObjectToViewPos(v.vertex).z;
}

void surf (Input IN, inout SurfaceOutput o) {
  fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
  o.Albedo = c.rgb * IN.color.rgb;
  o.Alpha = c.a * IN.color.a;
  // Do alpha test
  o.Alpha *= o.Alpha < _Cutoff ? 0 : 1;
  // Do proximity fade
  o.Alpha *= min(-IN.distance / _ProximityFade, 1);
  o.Normal = float3(0,0,IN.vface);
}
ENDCG
}


// MOBILE VERSION
SubShader {
  Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
  LOD 100
  Cull Off

CGPROGRAM
#pragma surface surf Lambert vertex:vert alpha:blend
#pragma multi_compile __ TBT_LINEAR_TARGET
#include "../../../Shaders/Include/Brush.cginc"
#pragma target 3.0

sampler2D _MainTex;
fixed4 _Color;
half _ProximityFade;
half _Cutoff;

struct Input {
  float2 uv_MainTex;
  float4 color : COLOR;
  fixed vface : VFACE;
  float distance;
};

void vert (inout appdata_full v, out Input o) {
  UNITY_INITIALIZE_OUTPUT(Input,o);
  o.color = TbVertToNative(v.color);
  o.distance = UnityObjectToViewPos(v.vertex).z;
}

void surf (Input IN, inout SurfaceOutput o) {
  fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
  o.Albedo = c.rgb * IN.color.rgb;
  o.Alpha = c.a * IN.color.a;
  // Do alpha test
  o.Alpha *= o.Alpha < _Cutoff ? 0 : 1;
  // Do proximity fade
  o.Alpha *= min(-IN.distance / _ProximityFade, 1);
  o.Normal = float3(0,0,IN.vface);
}
ENDCG
}

Fallback "Transparent/Cutout/VertexLit"
}
