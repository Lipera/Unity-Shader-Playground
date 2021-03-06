﻿Shader "ShaderDev/15Lighting_ambient" {
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

                        float4 specularMap = tex2Dlod(_SpecularMap, float4(o.texcoord.xy, 0, 0)); //using textcoordinate of main texture because map of specular should have the same structure as the main texture
                        float3 worldSpaceViewDir = normalize(_WorldSpaceCameraPos - o.posWorld);
                        float3 specularCol = SpecularBlinnPhong(o.normalWorld, lightDir, worldSpaceViewDir, specularMap.rgb, _SpecularFactor, attenuation, _SpecularPower);
                        o.surfaceColor = float4(diffuseCol + specularCol, 1);
                        #if _AMBIENTMODE_ON
                            float3 ambientColor = _AmbientFactor * UNITY_LIGHTMODEL_AMBIENT; //built-in variable that can be changed in the lighting section of the scene
                            o.surfaceColor = float4(o.surfaceColor.rgb + ambientColor, 1);
                        #endif
                    #endif
                    return o;
                }

                half4 frag(vertexOutput i) : COLOR {
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
                        
                        #if _AMBIENTMODE_ON
                            float3 ambientColor = _AmbientFactor * UNITY_LIGHTMODEL_AMBIENT; //built-in variable that can be changed in the lighting section of the scene
                            return float4(diffuseCol + specularCol + ambientColor, 1);
                        #else
                            return float4(diffuseCol + specularCol, 1);
                        #endif
                    #elif _LIGHTING_VERT
                        return float4(i.surfaceColor.xyz, 1);
                    #else
                        return float4(worldNormalAtPixel, 1);
                    #endif
                }

            ENDCG
        }
    }

    FallBack "Diffuse"
}