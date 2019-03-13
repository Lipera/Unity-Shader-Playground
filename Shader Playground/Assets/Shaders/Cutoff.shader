Shader "Holistic/Cutoff" {
	
	Properties {
		_MainText("Diffuse Texture", 2D) = "white" {}
		[Toggle] _rimBool("Rim Light", float) = 0
		_RimColor ("Rim Color", Color) = (0,0.5,0.5,0.0)
		_RimPower ("Rim Power", Range(0.5,8.0)) = 3.0
		_StripeHeight ("Stripe Height", Range(1, 20.0)) = 10.0
	}
	
	SubShader{
		CGPROGRAM

			#pragma surface surf Lambert

			struct Input {
				float2 uv_MainText;
				float3 viewDir;
				float3 worldPos;
			};

			sampler2D _MainText;
			float _rimBool;
			float4 _RimColor;
			float _RimPower;
			half _StripeHeight;

			void surf(Input IN, inout SurfaceOutput o) {
				o.Albedo = tex2D(_MainText, IN.uv_MainText).rgb;

				if(_rimBool) {
					half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal)); //dot -> dot product, saturate -> clamps values larger than 1 or smaller than 0
					o.Emission = frac(IN.worldPos.y * (20 - _StripeHeight) * 0.5) > 0.4 ? float3(0,1,0) * pow(rim, _RimPower) : float3(1,0,0) * pow(rim, _RimPower); //frac -> return the fractional part of the number provided
				}
			}
		ENDCG
	}
	Fallback "Diffuse"
}