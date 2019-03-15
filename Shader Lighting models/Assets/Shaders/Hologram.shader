Shader "Holistic/Hologram" {
	
	Properties {
		_RimColor ("Rim Color", Color) = (0,0.5,0.5,0.0)
		_RimPower ("Rim Power", Range(0.5, 8.0)) = 3.0
	}
	
	SubShader {
		Tags {
			"Queue" = "Transparent"
		}

		Pass {
			ZWrite ON //When object is in transparent queue, depth is not stored in Z buffer making some weird depth draws in the hologram object applied with this shader
					  //We make a pass, lines executed before the main shader code, to force the write to the Zbuffer
			ColorMask 0 //Makes so that no colored pixels are written to the frame buffer. You can switch this on to see where the Zbuffer data is being written.
		}

		CGPROGRAM

			#pragma surface surf Lambert alpha:fade

			struct Input {
				float3 viewDir;
			};

			float4 _RimColor;
			half _RimPower;

			void surf(Input IN, inout SurfaceOutput o) {
				half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal)); //dot -> dot product, saturate -> clamps values larger than 1 or smaller than 0
				o.Emission = _RimColor.rgb * pow(rim, _RimPower) * 10;
				o.Alpha = pow(rim, _RimPower);
			}

		ENDCG
	}
	Fallback "Diffuse"
}