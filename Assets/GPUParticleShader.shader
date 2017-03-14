Shader "Unlit/GPUParticleShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
            #pragma geometry geom
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

            struct v2g
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            struct g2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

            [maxvertexcount(32)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
            {
                g2f OUT;
                OUT.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

                OUT.vertex = IN[0].vertex;
                triStream.Append(OUT);

                OUT.vertex = IN[0].vertex + float4(1, 0, 0, 0);
                triStream.Append(OUT);

                OUT.vertex = IN[0].vertex + float4(1, 1, 0, 0);
                triStream.Append(OUT);

                triStream.RestartStrip();
                
                OUT.vertex = IN[1].vertex;
                triStream.Append(OUT);

                OUT.vertex = IN[1].vertex + float4(1, 0, 0, 0);
                triStream.Append(OUT);

                OUT.vertex = IN[1].vertex + float4(1, 1, 0, 0);
                triStream.Append(OUT);

                triStream.RestartStrip();

                OUT.vertex = IN[2].vertex;
                triStream.Append(OUT);

                OUT.vertex = IN[2].vertex + float4(1, 0, 0, 0);
                triStream.Append(OUT);

                OUT.vertex = IN[2].vertex + float4(1, 1, 0, 0);
                triStream.Append(OUT);
            }
			
			fixed4 frag (g2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
