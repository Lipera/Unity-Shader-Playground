Shader "Holistic/ColourVF"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION; //In world space
            };

            struct v2f
            {
                float4 vertex : SV_POSITION; //In clipping space
                float4 color : COLOR;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //Converts from world space to clipping space. It squashes the data down.
                //o.color.r = (v.vertex.x + 10) / 10;
                //o.color.g = (v.vertex.z + 10) / 10;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target //Processes are much heavier in the fragment shader than in the vertex shader. 
                                            //For this color effect it is best to do it in the vertex shader since the effect produced is the same when done in either vertex or fragment shader.
                                            //If you want the color values to be altered in the mesh and not change when you change scvreen position then it has to be done on the vertex shader.
            {
                fixed4 col;
                //col = i.color;
                col.r = i.vertex.x / 1000;
                col.g = i.vertex.y / 1000;
                return col;
            }
            ENDCG
        }
    }
}
