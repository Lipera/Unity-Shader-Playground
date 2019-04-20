﻿Shader "ShaderDev/19Lighting_IBLFresnel" {
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        [KeywordEnum(Off,On)] _UseNormal("Use Normal Map?", Float) = 0
        _Diffuse("Diffuse %", Range(0,1)) = 1
        [KeywordEnum(Off, Vert, Frag)] _Lighting("Lighting Mode", Float) = 0
        _SpecularMap("Specular Map", 2D) = "black" {}
        _SpecularFactor("Specular %", Range(0,1)) = 1
        _SpecularPower("Specular Power", Float) = 100
        [Toggle] _AmbientMode("Ambient Light?", Float) = 0
        _AmbientFactor("Ambient %", Range(0,1)) = 1

        [KeywordEnum(Off, Refl, Refr, Fres)] _IBLMode ("IBL Mode", Float) = 0
        _ReflectionFactor("Reflection %", Range(0,1)) = 1

        _Cube("Cube Map", Cube) = "" {}
        _Detail("Reflection Detail", Range(1,9)) = 1.0
        _Exposure("HDR Exposure", Float) = 1.0

        _RefractionFactor("Refraction %", Range(0,1)) = 1
        _RefractiveIndex("Refractive Index", Range(0,50)) = 1

        _FresnelWidth("Fresnel Width", Range(0,1)) = 0.3
    }

    SubShader {
        Tags { 
            "Queue" = "Transparent" 
            "IgnoreProjector" = "True" 
            "RenderType" = "Transparent"
        }

        Pass {
            Tags { "Lighting Mode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                //this line is used to compile several version of this shader based on the enums passed in the properties
                #pragma shader_feature _USENORMAL_OFF _USENORMAL_ON
                #pragma shader_feature _LIGHTING_OFF _LIGHTING_VERT _LIGHTING_FRAG
                #pragma shader_feature _AMBIENTMODE_OFF _AMBIENTMODE_ON
                #pragma shader_feature _IBLMODE_OFF _IBLMODE_REFL _IBLMODE_REFR _IBLMODE_FRES
                #include "CVGLighting.cginc"

                uniform half4 _Color;
                uniform sampler2D _MainTex;
                uniform float4 _MainTex_ST; //variable generated by unity to tile and offset texture

                uniform sampler2D _NormalMap;
                uniform float4 _NormalMap_ST;

                uniform float _Diffuse;
                uniform float4 _LightColor0;

                uniform sampler2D _SpecularMap;
                uniform float _SpecularFactor;                
                uniform float _SpecularPower;

                #if _IBLMODE_REFL || _IBLMODE_REFR || _IBLMODE_FRES
                    uniform samplerCUBE _Cube;
                    uniform half _Detail;
                    float _Exposure;
                #endif

                #if _IBLMODE_REFL || _IBLMODE_FRES
                    float _ReflectionFactor;
                #endif
                
                #if _IBLMODE_REFR
                    uniform float _RefractionFactor;
                    uniform float _RefractiveIndex;
                #endif

                #if _IBLMODE_FRES
                    uniform float _FresnelWidth;
                #endif

                #if _AMBIENTMODE_ON
                    uniform float _AmbientFactor;
                #endif

                struct vertexInput {
                    float4 vertex : POSITION;
                    float4 normal : NORMAL;
                    float4 texcoord : TEXCOORD0;
                    #if _USENORMAL_ON
                        float4 tangent : TANGENT;
                    #endif
                };

                struct vertexOutput {
                    float4 pos : SV_POSITION;
                    float4 texcoord : TEXCOORD0;
                    float4 normalWorld : TEXCOORD1; //MSDN Semantics does not have an attribute for normal or tangent so we place it in an element of the same type float4
                    float4 posWorld : TEXCOORD2;
                    #if _USENORMAL_ON
                        float4 tangentWorld : TEXCOORD3;
                        float3 binormalWorld : TEXCOORD4;
                        float4 normalTexCoord : TEXCOORD5;
                    #endif
                    #if _LIGHTING_VERT
                        float4 surfaceColor : COLOR0;
                    #else 
                        #if _IBLMODE_REFL || _IBLMODE_REFR || _IBLMODE_FRES
                            float4 surfaceColor : COLOR0;
                        #endif
                    #endif
                };

                vertexOutput vert(vertexInput v) {
                    vertexOutput o;
                    UNITY_INITIALIZE_OUTPUT(vertexOutput, o); //necessary for HLSL compilers
                    //o.pos = mul(UNITY_MATRIX_MVP, v.vertex); //this method is obsolete and couls not support all graph API's
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw); //x and y coordinates are for tilling. z and w coordinates are for offseting
                    o.normalWorld = float4(normalize(mul(normalize(v.normal.xyz), (float3x3)unity_WorldToObject)), v.normal.w);
                    o.posWorld = mul(unity_ObjectToWorld, v.vertex);

                    #if _USENORMAL_ON
                        // World space T, B, N values
                        o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);
                        o.tangentWorld = float4(normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz)), v.tangent.w);
                        o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);
                    #endif
                    #if _LIGHTING_VERT
                        float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                        float3 lightColor = _LightColor0.xyz;
                        float attenuation = 1;
                        float3 diffuseCol = DiffuseLambert(o.normalWorld, lightDir, lightColor, _Diffuse, attenuation);
                        float3 mainTexCol = tex2Dlod(_MainTex, float4(o.texcoord.xy, 0,0));

                        float4 specularMap = tex2Dlod(_SpecularMap, float4(o.texcoord.xy, 0, 0)); //using textcoordinate of main texture because map of specular should have the same structure as the main texture
                        float3 worldSpaceViewDir = normalize(_WorldSpaceCameraPos - o.posWorld);
                        float3 specularCol = SpecularBlinnPhong(o.normalWorld, lightDir, worldSpaceViewDir, specularMap.rgb, _SpecularFactor, attenuation, _SpecularPower);
                        o.surfaceColor = float4(mainTexCol * _Color * (diffuseCol + specularCol), 1);
                        #if _AMBIENTMODE_ON
                            float3 ambientColor = _AmbientFactor * UNITY_LIGHTMODEL_AMBIENT; //built-in variable that can be changed in the lighting section of the scene
                            o.surfaceColor = float4(o.surfaceColor.rgb + ambientColor, 1);
                        #endif

                        #if _IBLMODE_REFL
                            float3 worldRefl = reflect(-worldSpaceViewDir, o.normalWorld.xyz);
                            o.surfaceColor.rgb *= IBLRefl(_Cube, _Detail, worldRefl, _Exposure, _ReflectionFactor); //here we respect the lighting model so we multiply the result
                        #endif

                        #if _IBLMODE_REFR
                            float3 worldRefr = refract(-worldSpaceViewDir, o.normalWorld.xyz, 1/_RefractiveIndex); //last input is eta where we consider the first medium to be vacuum, hence the 1 in the nominator
                            o.surfaceColor.rgb *= IBLRefl(_Cube, _Detail, worldRefr, _Exposure, _RefractionFactor); //here we respect the lighting model so we multiply the result
                        #endif

                        #if _IBLMODE_FRES
                            float3 worldRefl = reflect(-worldSpaceViewDir, o.normalWorld.xyz);
                            float3 reflColor = IBLRefl(_Cube, _Detail, worldRefl, _Exposure, _ReflectionFactor);

                            float fresnel = 1 - saturate(dot(worldSpaceViewDir, o.normalWorld.xyz));
                            fresnel = smoothstep(1 - _FresnelWidth, 1, fresnel);
                            o.surfaceColor.rgb = lerp(o.surfaceColor.rgb, o.surfaceColor.rgb * reflColor, fresnel);
                        #endif
                    #endif
                    return o;
                }

                half4 frag(vertexOutput i) : COLOR {
                    float4 finalColor = float4(0,0,0,_Color.a);

                    #if _USENORMAL_ON
                        float3 worldNormalAtPixel = WorldNormalFromNormalMap(_NormalMap, i.normalTexCoord.xy, i.tangentWorld.xyz, i.binormalWorld.xyz, i.normalWorld.xyz);
                    #else
                        float3 worldNormalAtPixel = i.normalWorld.xyz;
                    #endif

                    #if _LIGHTING_FRAG
                        float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                        float3 lightColor = _LightColor0.xyz;
                        float attenuation = 1;
                        float3 diffuseCol = DiffuseLambert(worldNormalAtPixel, lightDir, lightColor, _Diffuse, attenuation);

                        float4 specularMap = tex2Dlod(_SpecularMap, float4(i.texcoord.xy, 0, 0)); //using textcoordinate of main texture because map of specular should have the same structure as the main texture
                        float3 worldSpaceViewDir = normalize(_WorldSpaceCameraPos - i.posWorld);
                        float3 specularCol = SpecularBlinnPhong(worldNormalAtPixel, lightDir, worldSpaceViewDir, specularMap.rgb, _SpecularFactor, attenuation, _SpecularPower);
                        
                        float3 mainTexCol = tex2D(_MainTex, i.texcoord.xy);
                        finalColor.rgb += mainTexCol * _Color * diffuseCol + specularCol;

                        #if _AMBIENTMODE_ON
                            float3 ambientColor = _AmbientFactor * UNITY_LIGHTMODEL_AMBIENT; //built-in variable that can be changed in the lighting section of the scene
                            finalColor.rgb += ambientColor;
                        #endif

                        #if _IBLMODE_REFL
                            float3 worldRefl = reflect(-worldSpaceViewDir, worldNormalAtPixel);
                            finalColor.rgb *= IBLRefl(_Cube, _Detail, worldRefl, _Exposure, _ReflectionFactor); //here we respect the lighting model so we multiply the result
                        #endif

                        #if _IBLMODE_REFR
                            float3 worldRefr = refract(-worldSpaceViewDir, worldNormalAtPixel, 1/_RefractiveIndex);
                            finalColor.rgb *= IBLRefl(_Cube, _Detail, worldRefr, _Exposure, _RefractionFactor); //here we respect the lighting model so we multiply the result
                        #endif

                        #if _IBLMODE_FRES
                            float3 worldRefl = reflect(-worldSpaceViewDir, worldNormalAtPixel);
                            float3 reflColor = IBLRefl(_Cube, _Detail, worldRefl, _Exposure, _ReflectionFactor);

                            float fresnel = 1 - saturate(dot(worldSpaceViewDir, worldNormalAtPixel));
                            fresnel = smoothstep(1 - _FresnelWidth, 1, fresnel);
                            finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb * reflColor, fresnel);
                        #endif
                    #elif _LIGHTING_VERT
                        finalColor = i.surfaceColor;
                    #else
                        #if _IBLMODE_REFL
                            float3 worldSpaceViewDir = normalize(_WorldSpaceCameraPos - i.posWorld);
                            float3 worldRefl = reflect(-worldSpaceViewDir, worldNormalAtPixel);
                            finalColor.rgb += IBLRefl(_Cube, _Detail, worldRefl, _Exposure, _ReflectionFactor); //here we don't have a lighting model so we add the result
                        #endif

                        #if _IBLMODE_REFR
                            float3 worldSpaceViewDir = normalize(_WorldSpaceCameraPos - i.posWorld);
                            float3 worldRefr = refract(-worldSpaceViewDir, worldNormalAtPixel, 1/_RefractiveIndex);
                            finalColor.rgb += IBLRefl(_Cube, _Detail, worldRefr, _Exposure, _RefractionFactor); //here we don't have a lighting model so we add the result
                        #endif

                        #if _IBLMODE_FRES
                            float3 worldSpaceViewDir = normalize(_WorldSpaceCameraPos - i.posWorld);
                            float3 worldRefl = reflect(-worldSpaceViewDir, worldNormalAtPixel);
                            float3 reflColor = IBLRefl(_Cube, _Detail, worldRefl, _Exposure, _ReflectionFactor);

                            float fresnel = 1 - saturate(dot(worldSpaceViewDir, worldNormalAtPixel));
                            fresnel = smoothstep(1 - _FresnelWidth, 1, fresnel);
                            float3 mainTexCol = tex2D(_MainTex, i.texcoord.xy);

                            finalColor.rgb = lerp(mainTexCol * _Color.rgb, finalColor.rgb + reflColor, fresnel); //here we add the reflection color because there is no lighting applied in the finalColor
                        #endif
                    #endif

                    return finalColor;
                }

            ENDCG
        }
    }

    FallBack "Diffuse"
}