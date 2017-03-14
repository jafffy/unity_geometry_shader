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

            [maxvertexcount(128)]
            void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
            {
                g2f OUT;
                OUT.uv = IN[0].uv; // (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

                float4 v = IN[0].vertex;
                float4 v_prime = v + float4(0, -1, 0, 0);

                const float Pi = 3.141592;
                const int SEGMENT_COUNT = 32;
                for ( int s = 0; s <= SEGMENT_COUNT; ++s ) {
                    float t1 = (float) s / SEGMENT_COUNT * 2 * Pi;
                    float t2 = (float) (s + 1) / SEGMENT_COUNT * 2 * Pi;

                    OUT.vertex = v;
                    triStream.Append(OUT);

                    OUT.vertex = v_prime + float4(cos(t1), sin(t1), 0, 0);
                    triStream.Append(OUT);

                    OUT.vertex = v;
                    triStream.Append(OUT);

                    OUT.vertex = v_prime + float4(cos(t2), sin(t2), 0, 0);
                    triStream.Append(OUT);
                }

                triStream.RestartStrip();
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
