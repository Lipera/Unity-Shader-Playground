Shader "Holistic/AllProps" {

	Properties{
		_myColour("Example Colour", Color) = (1,1,1,1)
		_myRange("Texture Color Intensity", Range(0,5)) = 1
		_colourIntensity("Normal Color Intensity", Range(0,5)) = 0.5
		_myTex("Example Texture", 2D) = "white" {}
		_myCube("Example Cube", CUBE) = "" {}
		_myFloat("Example Float", Float) = 0.5
		_myVector("Example Vector", Vector) = (0.5,1,1,1)
	}

		SubShader{

			CGPROGRAM
				#pragma surface surf Lambert

				fixed4 _myColour;
				half _myRange;
				half _colourIntensity;
				sampler2D _myTex;
				samplerCUBE _myCube;
				float _myFloat;
				float4 _myVector;

				struct Input {
					float2 uv_myTex;
					float3 worldRefl;
				};

				void surf(Input IN, inout SurfaceOutput o) {
					if(_colourIntensity == 0) {
						o.Albedo = ((tex2D(_myTex, IN.uv_myTex)) * _myRange).rgb;
					} else {
						o.Albedo = ((tex2D(_myTex, IN.uv_myTex) * _myColour * _colourIntensity) * _myRange).rgb;
					}

					o.Emission = texCUBE(_myCube, IN.worldRefl).rgb;
				}
			ENDCG
	}

		Fallback "Diffuse"
}