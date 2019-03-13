Shader "Holistic/PropChallenge2" 
{
    Properties {
        _myTex ("Example Texture", 2D) = "white" {}
    }
    SubShader {

      CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _myTex;
        fixed4 _myColor;

        struct Input {
            float2 uv_myTex;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = (tex2D(_myTex, IN.uv_myTex)).rgb;
            o.Albedo.g = 1;
        }
      
      ENDCG
    }
    Fallback "Diffuse"
  }
