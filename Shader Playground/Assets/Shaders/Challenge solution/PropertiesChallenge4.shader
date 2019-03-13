Shader "Holistic/PropChallenge4" 
{
    Properties {
        _myTex ("Texture", 2D) = "white" {}

        //set this texture to black to stop the white
        //overwhelming the effect if no emission texture
        //is present
        _myEmis ("Texture", 2D) = "black" {}
    }
    SubShader {

      CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _myTex;
        sampler2D _myEmis;

        struct Input {
            float2 uv_myTex;
            float2 uv_myEmis;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = (tex2D(_myTex, IN.uv_myTex)).rgb;
            o.Emission = (tex2D(_myEmis, IN.uv_myEmis)).rgb;
        }
      
      ENDCG
    }
    Fallback "Diffuse"
  }
