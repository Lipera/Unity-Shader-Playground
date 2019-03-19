Shader "Holistic/AdvancedOutline" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Colour", Color) = (1,1,1,1)
        _Outline ("Outline Width", Range(.002, .3)) = .005
    }

    //In this shader we have 2 passes. The first is the regular one that draws the model.
    //The second we draw an extruded version of the model but cull the front of it so it doesn't overlap with the real model. 
    //We only see the the interior of the enlarged model, made only big enough so that we have the illusion of an outline.
    //NOTE: This shader is not well suited for more blocky shapes like cubes. Check http://wiki.unity3d.com/index.php/Silhouette-Outlined_Diffuse for more general case
    SubShader {
        CGPROGRAM
            #pragma surface surf Lambert

            struct Input {
                float2 uv_MainTex;
            };

            sampler2D _MainTex;

            void surf (Input IN, inout SurfaceOutput o) {
                o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
            }
        ENDCG

        Pass {
            Cull Front

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f {
                    float4 pos : SV_POSITION;
                    fixed4 color : COLOR;
                };

                float _Outline;
                float4 _OutlineColor;

                v2f vert(appdata v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);

                    float3 norm = normalize(mul((float3x3) UNITY_MATRIX_IT_MV, v.normal));
                    float2 offset = TransformViewToProjection(norm.xy);

                    o.pos.xy += offset * o.pos.z * _Outline; //offset gives you the direction to expand.
                                                             //o.pos.z gives you a scaling factor that will make the outline scale with distance from the camera - this keeps it close to the same thickness no matter how far away from the camera it is.
                                                             //_Outline gives you the thickness of the outline.
                    o.color = _OutlineColor;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target {
                    return i.color;
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
