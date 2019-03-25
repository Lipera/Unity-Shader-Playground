Shader "ShaderDev/BareBone" 
{
    Properties 
    {
        _Color ("Main Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent" 
            "IgnoreProjector" = "True" 
            "RenderType" = "Transparent"
        }

        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                uniform half4 _Color;

                struct vertexInput
                {
                    float4 vertex : POSITION;
                };

                struct vertexOutput
                {
                    float4 pos : SV_POSITION;
                };

                vertexOutput vert(vertexInput v) 
                {
                    vertexOutput o;
                    //o.pos = mul(UNITY_MATRIX_MVP, v.vertex); //this method is obsolete and couls not support all graph API's
                    o.pos = UnityObjectToClipPos(v.vertex);
                    return o;
                }

                half4 frag(vertexOutput i) : COLOR 
                {
                    return _Color;
                }

            ENDCG
        }
    }

    FallBack "Diffuse"
}