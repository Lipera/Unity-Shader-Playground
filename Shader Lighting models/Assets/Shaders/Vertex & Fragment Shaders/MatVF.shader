Shader "Holistic/MatVF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScaleUVX ("Scale Ripple in X direction", Range(1, 10)) = 1
        _ScaleUVY ("Scale Ripple in Y direction", Range(1, 10)) = 1
    }
    SubShader
    {
        Tags {
            "Queue" = "Transparent" //Put in this queue so it does not recursively redraw itself over and over again
        }

        GrabPass {} //Grabs the color of the pixels that are about to appear on the screen
        
        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    fixed4 color : COLOR;
                };

                sampler2D _GrabTexture; //built-in variable that contains colors extracted from GrabPass block
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _ScaleUVX;
                float _ScaleUVY;

                v2f vert (appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    
                    //add this to flip if UV upside down
                    #if UNITY_UV_STARTS_AT_TOP
                        float flipscale = -1.0;
                    #else
                        float flipscale = 1.0;
                    #endif

                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.uv.x = sin(o.uv.x * _ScaleUVX);
                    o.uv.y = sin(o.uv.y * _ScaleUVY /* flipscale*/); //TODO Flipscale trick does not seem to do it. Investigate how to debug this.
                    //o.color.r = v.vertex.x;
                    //o.color.g = v.vertex.z;
                    return o;
                }

                fixed4 frag (v2f i) : SV_Target
                {
                    // sample the texture
                    fixed4 col = tex2D(_GrabTexture, i.uv);
                    //fixed4 col = i.color;
                    return col;
                }
            ENDCG
        }
    }
}
