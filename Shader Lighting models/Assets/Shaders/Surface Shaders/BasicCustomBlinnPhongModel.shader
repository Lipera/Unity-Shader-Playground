Shader "Holistic/BasicCustomBlinnPhongModel"
{
    Properties
    {
        _Colour ("Colour", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { 
            "Queue" = "Geometry" 
        }

        CGPROGRAM
            #pragma surface surf BasicBlinnPhong

            half4 LightingBasicBlinnPhong(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
                half h = normalize(lightDir + viewDir);

                half diff = max(0, dot(s.Normal, lightDir));

                float nh = max(0, dot(s.Normal, h));
                float spec = pow(nh, 48.0);

                half4 c;
                c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
                //c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten * _SinTime; //Effect for challenge 4, _SinTime is a built-in variable that changes values between 0 and 1 overtime during application runtime
                c.a = s.Alpha;
                return c;
            }

            float4 _Colour;

            struct Input {
                float2 uv_MainTex;
            };

            void surf (Input IN, inout SurfaceOutput o) {
                o.Albedo = _Colour.rgb;
            }
        ENDCG
    }
    FallBack "Diffuse"
}
