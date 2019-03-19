Shader "Holistic/SimpleOutline" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Colour", Color) = (1,1,1,1)
        _Outline ("Outline Width", Range(.002, .1)) = .005
    }

    SubShader {

        //This shader needs to be in the tranparent render queue so that the background is not drawn over the outline when the depth buffer is turned off
        //This is a simple way to achieve outline, but not the recommended since it will originate problem when you start having transparent object in your scene
        Tags {
            "Queue" = "Transparent"
        }

        ZWrite OFF

        //First pass for the colored model that is slightly bigger than the model so that the outline is shown
        CGPROGRAM
            #pragma surface surf Lambert vertex:vert

            struct Input {
                float uv_MainTex;
            };

            float _Outline;
            float4 _OutlineColor;

            void vert(inout appdata_full v) {
                v.vertex.xyz += v.normal * _Outline; //to have model bigger, we slightly extrude the model out
            }

            sampler2D _MainTex;

            void surf(Input IN, inout SurfaceOutput o) {
                o.Emission = _OutlineColor.rgb; //Outline color to the emission channel so that it is always visible
            }
        ENDCG

        ZWrite ON

        //Second pass with the standard default shader the slaps the diffuse texture onto the model
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
    }
    FallBack "Diffuse"
}
