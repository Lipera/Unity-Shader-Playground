Shader "Holistic/ScrollWavingWater" {
    Properties {
        _MainTex ("Water", 2D) = "white" {}
        _FoamTex ("Foam", 2D) = "white" {}
        _ScrollX ("Scroll X", Range(-5,5)) = 1
        _ScrollY ("Scroll Y", Range(-5,5)) = 1
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
                o.vertColor = 1; //used to give color variation in the lowest and hightest points of the mesh when it is waving
            }
            
            float _ScrollX;
            float _ScrollY;
            sampler2D _MainTex;
            sampler2D _FoamTex;

            void surf(Input IN, inout SurfaceOutput o) {
                _ScrollX *= _Time;
                _ScrollY *= _Time;
                float3 water = (tex2D(_MainTex, IN.uv_MainTex + float2(_ScrollX, _ScrollY))).rgb;
                float3 foam = (tex2D(_FoamTex, IN.uv_MainTex + float2(_ScrollX / 2, _ScrollY / 2))).rgb; //Here we are taking our second texture and slowing it down
                                                                                                         //compared to first to have a paralax effect
                o.Albedo = (water + foam) / 2.0;
            }
        ENDCG
    }
}
