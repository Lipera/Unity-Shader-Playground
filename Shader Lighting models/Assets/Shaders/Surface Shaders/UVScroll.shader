Shader "Holistic/UVScroll" {
    Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _ScrollX ("Scroll X", Range(-5,5)) = 1
        _ScrollY ("Scroll Y", Range(-5,5)) = 1
    }

    SubShader {
        CGPROGRAM
            #pragma surface surf Lambert

            float _ScrollX;
            float _ScrollY;
            sampler2D _MainTex;

            struct Input {
                float2 uv_MainTex;
            };

            void surf (Input IN, inout SurfaceOutput o) {
                _ScrollX *= _Time;
                _ScrollY *= _Time;
                float2 newuv = IN.uv_MainTex + float2(_ScrollX, _ScrollY);
                o.Albedo = tex2D(_MainTex, newuv);
            }
        ENDCG
    }
    FallBack "Diffuse"
}
