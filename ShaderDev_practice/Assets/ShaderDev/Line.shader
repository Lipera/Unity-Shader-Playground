﻿Shader "ShaderDev/04Line"  {

    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Start ("Line Start", FLoat) = 0.5
        _Width ("Line Width", Float) = 0.1
    }

    SubShader {
        Tags { 
            "Queue" = "Transparent" 
            "IgnoreProjector" = "True" 
            "RenderType" = "Transparent"
        }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                uniform half4 _Color;
                uniform sampler2D _MainTex;
                uniform float4 _MainTex_ST; //variable generated by unity to tile and offset texture
                uniform float _Start;
                uniform float _Width;

                struct vertexInput {
                    float4 vertex : POSITION;
                    float4 texcoord : TEXCOORD0;
                };

                struct vertexOutput {
                    float4 pos : SV_POSITION;
                    float4 texcoord : TEXCOORD0;
                };

                vertexOutput vert(vertexInput v) {
                    vertexOutput o;
                    UNITY_INITIALIZE_OUTPUT(vertexOutput, o); //necessary for HLSL compilers
                    //o.pos = mul(UNITY_MATRIX_MVP, v.vertex); //this method is obsolete and couls not support all graph API's
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw); //x and y coordinates are for tilling. z and w coordinates are for offseting
                    return o;
                }

                float drawLine(float2 uv, float start, float end) {
                    if(uv.x > start && uv.x < end) {
                        return 1;
                    }
                    return 0;
                }

                half4 frag(vertexOutput i) : COLOR {
                    float4 col = tex2D(_MainTex, i.texcoord) * _Color;
                    //col.a = sqrt(i.texcoord.x);
                    //col.a = sin(i.texcoord.x * 20);
                    col.a = drawLine(i.texcoord, _Start, _Start + _Width);
                    return col;
                }
            ENDCG
        }
    }

    FallBack "Diffuse"
}