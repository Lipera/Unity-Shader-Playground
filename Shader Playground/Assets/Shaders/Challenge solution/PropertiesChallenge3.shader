Shader "Holistic/PropChallenge3" 
{
    Properties {
        _myTex ("Example Texture", 2D) = "white" {}
    }
    SubShader {

      CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _myTex;

        struct Input {
            float2 uv_myTex;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            //note below how to create a colour on the fly with code
            float4 green = float4(0,1,0,1);
            o.Albedo = (tex2D(_myTex, IN.uv_myTex) * green).rgb;
        }
      
      ENDCG
    }
    Fallback "Diffuse"
  }
