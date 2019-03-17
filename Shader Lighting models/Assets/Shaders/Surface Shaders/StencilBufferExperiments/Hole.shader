Shader "Holistic/Hole"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { 
            "Queue" = "Geometry-1" //gets drawn before the geometry
        }

        ColorMask 0
        ZWrite OFF
        Stencil { //Same dimensions as the frame buffer
            Ref 1 //We write value of 1 for pixel that belongs to the object with this shader
            Comp always //When do we write to the stencil buffer? In this case, always overide value inside stencil buffer
            Pass replace //Action to be done if comparison passes. In this case we do a draw call and replace anything in the frame buffer with this pixel pass
        }

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
