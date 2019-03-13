Shader "Holistic/PropChallenge1" 
{
    Properties {
        _myColor ("Example Color", Color) = (1,1,1,1)
        _myRange ("Example Range", Range(0,5)) = 1
        _myTex ("Example Texture", 2D) = "white" {}
        _myCube ("Example Cube", CUBE) = "" {}
        _myFloat ("Example Float", Float) = 0.5
        _myVector ("Example Vector", Vector) = (0.5,1,1,1)
    }
    SubShader {

      CGPROGRAM
        #pragma surface surf Lambert
        
        fixed4 _myColor;
        half _myRange;
        sampler2D _myTex;
        samplerCUBE _myCube;
        float _myFloat;
        float4 _myVector;

        struct Input {
            float2 uv_myTex;
            float3 worldRefl;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = (tex2D(_myTex, IN.uv_myTex) * _myRange * _myColor).rgb;
            o.Emission = texCUBE (_myCube, IN.worldRefl).rgb;
        }
      
      ENDCG
    }
    Fallback "Diffuse"
  }
