Shader "Holistic/CustomToonRamp"
{
    Properties
    {
        _Colour ("Colour", Color) = (1,1,1,1)
        _RampTex ("Ramp Texture", 2D) = "white" {}
    }

    SubShader
    {
        CGPROGRAM
            #pragma surface surf ToonRamp

            float4 _Colour;
            sampler2D _RampTex;

            float4 LightingToonRamp(SurfaceOutput s, fixed3 lightDir, fixed atten) {
                float diff = dot (s.Normal, lightDir);
                float h = diff * 0.5 + 0.5;
                float2 rh = h;
                float3 ramp = tex2D(_RampTex, rh).rgb;
                
                float4 c;
                c.rgb = s.Albedo * _LightColor0.rgb * (ramp);
                c.a = s.Alpha;
                return c;
            }

            struct Input {
                float2 uv_RampTex;
                float3 viewDir;
            };

            void surf (Input IN, inout SurfaceOutput o) {
                float diff = dot (o.Normal, IN.viewDir);
                float h = diff * 0.5 + 0.5;
                float2 rh = h;
                float3 ramp = tex2D(_RampTex, rh).rgb;

                o.Albedo = _Colour.rgb * ramp;
            }
        ENDCG
    }
    FallBack "Diffuse"
}
