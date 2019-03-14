Shader "Holistic/BasicBlinnPhong"
{
    Properties
    {
        _Colour ("Colour", Color) = (1,1,1,1)
        _SpecColor ("Specular Colour", Color) = (1,1,1,1) //No need to define this variable since it is already defined by Unity
        _Spec ("Specular", Range(0,1)) = 0.5
        _Gloss ("Gloss", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags { 
            "Queu" = "Geometry" 
        }

        CGPROGRAM
            #pragma surface surf BlinnPhong

            float4 _Colour;
            half _Spec;
            fixed _Gloss;

            struct Input {
                float2 uv_MainTex;
            };

            void surf (Input IN, inout SurfaceOutput o) {
                o.Albedo = _Colour.rgb;
                o.Specular = _Spec;
                o.Gloss = _Gloss;
            }
        ENDCG
    }
    FallBack "Diffuse"
}
