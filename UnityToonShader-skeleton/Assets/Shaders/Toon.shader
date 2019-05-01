Shader "Custom/Toon" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        [KeywordEnum(Ramp, ShadingLvl, TwoTone)] _ToonMode ("Toon Mode", Float) = 0
        [ShowIf(_TOONMODE_RAMP)]_RampTex ("Ramp", 2D) = "white" {}
        [ShowIf(_TOONMODE_SHADINGLVL)]_CelShadingLevels ("Shading levels", Range(0,10)) = 5.5
    }
    SubShader {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Toon fullforwardshadows
        #pragma shader_feature _TOONMODE_RAMP _TOONMODE_SHADINGLVL _TOONMODE_TWOTONE

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        #if _TOONMODE_RAMP
            sampler2D _RampTex;
        #endif

        #if _TOONMODE_SHADINGLVL
            float _CelShadingLevels;
        #endif

        struct Input {
            float2 uv_MainTex;
            float2 uv_RampTex;
        };

        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        fixed4 LightingToon(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten) {
            //First calculate the dot product of the lightDir and the surface normal
            half NdotL = saturate(dot(s.Normal, lightDir));

            #if _TOONMODE_RAMP
                //Remap NdotL to the value on the ramp map
                half uvNdotL = NdotL * 0.5 + 0.5;
                NdotL = tex2D(_RampTex, fixed2(uvNdotL, 0.5));
            #endif

            #if _TOONMODE_SHADINGLVL
                //Snap the color
                NdotL = floor(NdotL * _CelShadingLevels) / (_CelShadingLevels - 0.5);
            #endif

            half4 color;

            color.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
            color.a = s.Alpha;

            return color;
        }

        void surf (Input IN, inout SurfaceOutput o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
