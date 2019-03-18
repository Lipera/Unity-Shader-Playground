Shader "Holistic/DiffuseShadowsVF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" } //Lights are calculated as a per model basis, contrary to deffered lighting

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight 
                //line to ignore lightmaps to process the shadow of another object onto this one

                #include "UnityCG.cginc"
                #include "UnityLightingCommon.cginc"
                #include "Lighting.cginc"
                #include "AutoLight.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    fixed4 diff : COLOR0;
                    float4 pos : SV_POSITION; //this name needs to be pos because of shadow function TRANSFER_SHADOW that searches for attribute with this name
                    SHADOW_COORDS(1)
                };

                v2f vert (appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                    o.diff = nl * _LightColor0;
                    TRANSFER_SHADOW(o)

                    return o;
                }

                sampler2D _MainTex;

                fixed4 frag (v2f i) : SV_Target
                {
                    // sample the texture
                    fixed4 col = tex2D(_MainTex, i.uv);
                    fixed shadow = SHADOW_ATTENUATION(i);
                    col *= i.diff * shadow;
                    return col;
                }
            ENDCG
        }

        Pass //Pass to cast shadows onto other objects
        {
            Tags { "LightMode" = "ShadowCaster" } //Mode to project shadows

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_shadowcaster
                
                #include "UnityCG.cginc"

                struct appdata 
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float4 textcoord : TEXCOORD0;
                };

                struct v2f 
                {
                    V2F_SHADOW_CASTER;
                };

                v2f vert(appdata v) 
                {
                    v2f o;
                    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o); //transforms the appdata struct into a V2F_SHADOW_CASTER
                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    SHADOW_CASTER_FRAGMENT(i);
                }
            ENDCG
        }
    }
}
