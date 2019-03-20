Shader "Holistic/Waves" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint ("Color Tint", Color) = (1,1,1,1)
        _Freq ("Frequency", Range(0,5)) = 3
        _Speed ("Speed", Range(0,100)) = 10
        _Amp ("Amplitude", Range(0,1)) = .5
    }

    SubShader {
        CGPROGRAM
            #pragma surface surf Lambert vertex:vert

            struct Input {
                float2 uv_MainTex;
                float3 vertColor;
            };

            float4 _Tint;
            float _Freq;
            float _Speed;
            float _Amp;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord2 : TEXCOORD2;
            };

            void vert (inout appdata v, out Input o) {
                UNITY_INITIALIZE_OUTPUT(Input,o);
                float t = _Time * _Speed;
                float waveHeight = sin(t + v.vertex.x * _Freq) * _Amp +
                                   sin(t * 2 + v.vertex.x * _Freq * 2) * _Amp; //wave is done in the direction of x. To have be circular change the t + v.vertex.x here.
                                                                               //Multiple sin function give a more complex motion pattern
                float waveHeightZ = sin(t + v.vertex.z * _Freq) * _Amp + 
                                    sin(t * 2 + v.vertex.z * _Freq * 2) * _Amp;
                v.vertex.y = v.vertex.y + waveHeight + waveHeightZ; //Here we update the render of the vertex, we don't affect the mesh itself in any way
                v.normal = normalize(float3(v.normal.x + waveHeight, v.normal.y, v.normal.z)); //to do the circular wave, the normals here also have to be changed to avoid weird shadows and other operations that involve normals.
                o.vertColor = waveHeight + 2; //used to give color variation in the lowest and hightest points of the mesh when it is waving
            }
            
            sampler2D _MainTex;

            void surf(Input IN, inout SurfaceOutput o) {
                float4 c = tex2D(_MainTex, IN.uv_MainTex);
                o.Albedo = c * IN.vertColor.rgb;
            }
        ENDCG
    }
}
