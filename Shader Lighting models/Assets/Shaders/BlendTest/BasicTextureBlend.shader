Shader "Holistic/BasicTextureBlend"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _DecalTex ("Decal Texture", 2D) = "white" {}
        [Toggle] _ShowDecal("Show Decal ?", Float) = 0
    }
    SubShader
    {
        Tags { 
            "Queue" = "Geometry" 
        }

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        sampler2D _DecalTex;
        half _ShowDecal;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 a = tex2D (_DecalTex, IN.uv_MainTex) * _ShowDecal; //if _ShowDecal is false, ie 0, the color will be black and hence be ignored
            o.Albedo = a.r > 0.9 ? a.rgb : c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
