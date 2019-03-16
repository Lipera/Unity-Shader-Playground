Shader "Holistic/StencilWindow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

        _SRef("Stencil Ref", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _SComp("Stencil Comp", Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)] _SOp("Stencil Op", Float) = 2
    }
    SubShader
    {
        Tags { 
            "Queue" = "Geometry-1" 
        }

        ZWrite OFF
        ColorMask 0

        Stencil {
            Ref[_SRef]
            Comp[_SComp]
            Pass[_SOp]
        }

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _myDiffuse;

        struct Input
        {
            float2 uv_myDiffuse;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_myDiffuse, IN.uv_myDiffuse);
            o.Albedo = c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
