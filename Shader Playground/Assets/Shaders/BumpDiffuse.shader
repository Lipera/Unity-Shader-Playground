Shader "Holistic/BumpDiffuse" {

	Properties{
		_myDiffuse("Diffuse Texture", 2D) = "white" {}
		_myBump("Normal Texture", 2D) = "bump" {}
		_mySlider("Bump Amount", Range(0,10)) = 1
		_myBright("Brightness Amount", Range(0,10)) = 1
	}

		SubShader{

			CGPROGRAM

				#pragma surface surf Lambert

				sampler2D _myDiffuse;
				sampler2D _myBump;
				half _mySlider;
				half _myBright;

				struct Input {
					float2 uv_myDiffuse;
					float2 uv_myBump;
				};

				void surf(Input IN, inout SurfaceOutput o) {
					o.Albedo = (tex2D(_myDiffuse, IN.uv_myDiffuse) * _myBright).rgb;
					o.Normal = UnpackNormal(tex2D(_myBump, IN.uv_myBump)); //function that converts 2D normal texture into normal. x -> -1 to 1, y -1 to 1, z -> -1 to 0
					o.Normal *= float3(_mySlider, _mySlider, 1); //we leave the z as it is as multiplying would make the model brighter
				}

			ENDCG
	}

		Fallback "Diffuse"
}