Shader "Holistic/Transparent" {
    Properties {
        _MainTex ("Main Texture", 2D) = "black" {}
    }

    SubShader {
        Tags { 
            "Queue" = "Transparent" 
        }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull OFF //Turning backface culling off
        Pass {
            SetTexture [_MainTex] { combine texture }
        }
    }
    FallBack "Diffuse"
}
