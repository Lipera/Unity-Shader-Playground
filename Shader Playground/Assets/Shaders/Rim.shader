Shader "Holistic/Rim" {
	
	Properties {
		_RimColor ("Rim Color", Color) = (0,0.5,0.5,0.0)
		_RimPower ("Rim Power", Range(0.5, 8.0)) = 3.0
	}
	
	SubShader{
		CGPROGRAM

			#pragma surface surf Lambert

			struct Input {
				float3 viewDir;
			};

			float4 _RimColor;
			half _RimPower;

			void surf(Input IN, inout SurfaceOutput o) {
				half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal)); //dot -> dot product, saturate -> clamps values larger than 1 or smaller than 0
				o.Emission = _RimColor.rgb * pow(rim, _RimPower);
			}

		ENDCG
	}
	Fallback "Diffuse"
}