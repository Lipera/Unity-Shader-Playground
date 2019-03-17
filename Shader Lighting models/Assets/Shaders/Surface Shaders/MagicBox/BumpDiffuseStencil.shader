Shader "Holistic/BumpDiffuseStencil"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _myDiffuse("Diffuse Texture", 2D) = "white" {}
        _myBump("Bump Texture", 2D) = "bump" {}
        _mySlider("Bump Amount", Range(0,10)) = 1

        _SRef("Stencil Ref", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _SComp("Stencil Comp", Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)] _SOp("Stencil Op", Float) = 2
    }
    SubShader
    {
        Tags { 
            "Queue" = "Geometry" 
        }

        Stencil {
            Ref[_SRef]
            Comp[_SComp]
            Pass[_SOp]
        }

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _myDiffuse;
        sampler2D _myBump;
        half _mySlider;
        float4 _Color;

        struct Input
        {
            float2 uv_myDiffuse;
            float2 uv_myBump;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_myDiffuse, IN.uv_myDiffuse) * _Color;
            o.Albedo = c.rgb;

            o.Normal = UnpackNormal(tex2D(_myBump, IN.uv_myBump));
            o.Normal *= float3(_mySlider, _mySlider, 1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
