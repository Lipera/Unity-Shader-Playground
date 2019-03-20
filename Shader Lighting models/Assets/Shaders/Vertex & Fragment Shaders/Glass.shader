Shader "Holistic/Glass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_ScaleUV ("Scale", Range(1,1000)) = 1
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent"}
		GrabPass{}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 uvgrab : TEXCOORD1;
				float2 uvbump : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			float4 _GrabTexture_TexelSize;
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float _ScaleUV;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				//o.uvgrab.xy = (float2(o.vertex.x, -o.vertex.y) + o.vertex.w) * .5; //vertex values are [-1;1] and textcoord should be in [0;1]. 
																				  //We add o.vertex.w because it will then be divided by itself in tex2Dproj (check http://developer.download.nvidia.com/cg/tex2Dproj.html)
				//o.uvgrab.zw = o.vertex.zw;
				
				//these 2 lines can be replaced by the following one. 
				//It is best practise to use this one since origin of uv is different for different Libraries and this function encapsulates that
				//In Direct3D, used in windows, origin is top-left. In OpenGL, used in Mac and Linux, origin is bottom-left.
				o.uvgrab = ComputeScreenPos(o.vertex);
				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvbump = TRANSFORM_TEX(v.uv, _BumpMap);
				return o;
			}

			sampler2D _GrabTexture;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			
			fixed4 frag (v2f i) : SV_Target
			{
				half2 bump = UnpackNormal(tex2D(_BumpMap, i.uvbump)).rg;
				float2 offset = bump * _ScaleUV * _GrabTexture_TexelSize.xy;
				i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;

				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
				fixed4 tint = tex2D(_MainTex, i.uv);
				col *= tint;
				return col;
			}
			ENDCG
		}
	}
}
