Shader "Holistic/BlendTestOneOne"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent" 
        }
        Blend One One //First argument is the SrcFactor (incoming color), second is the DestFactor (frame buffer color). 
                        //You can then use the different built-in keywords to do the blending. 
                        //The 2 colors are multiplied by the value of the keyword and then added together to create the final color.
                        //Check https://docs.unity3d.com/Manual/SL-Blend.html for more info.
        //Blend SrcAlpha OneMinusSrcAlpha //Traditional Blend
        //Blend DstColor Zero //Soft Additive Blend
        Pass 
        {
            SetTexture[_MainTex] { combine texture }
        }
    }
    FallBack "Diffuse"
}
