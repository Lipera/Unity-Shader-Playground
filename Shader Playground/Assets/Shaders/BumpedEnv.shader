Shader "Holistic/BumpedEnvironment" {
	Properties {
		_myDiffuse ("Diffuse Texture", 2D) = "white" {}
		_myBump ("Bump Texture", 2D) = "bump" {}
		_mySlider ("Bumo Amount", Range(0,10)) = 1
		_myBright ("Brightness", Range(0,10)) = 1
		_myCube("Cube Map", CUBE) = "white" {}
	}
	SubShader {
		CGPROGRAM
			#pragma surface surf Lambert

			sampler2D _myDiffuse;
			sampler2D _myBump;
			half _mySlider;
			half _myBright;
			samplerCUBE _myCube;

			struct Input {
				float2 uv_myDiffuse;
				float2 uv_myBump;
				float3 worldRefl; INTERNAL_DATA //Needed when editing o.Normal since worldRefl and o.Normal are linked
			};

			void surf (Input IN, inout SurfaceOutput o) {
				o.Albedo = tex2D(_myDiffuse, IN.uv_myDiffuse).rgb;
				o.Normal = UnpackNormal(tex2D(_myBump, IN.uv_myBump)) * _myBright;
				o.Normal *= float3(_mySlider, _mySlider, 1);
				o.Emission = texCUBE(_myCube, WorldReflectionVector(IN, o.Normal)).rgb;
			}
		ENDCG
	}
	FallBack "Diffuse"
}
