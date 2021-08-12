Shader "GS202/Lesson3/UseTex"
{
    Properties {
        _MainTex("Main Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNorm : TEXCOORD1;
            };

            sampler2D _MainTex;
            // S:scale T:translate
            float4 _MainTex_ST;

            v2f vert(appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // .25 .25 -> .5 .5  [0,.5]
                // .75 .75 -> 1.5 1.5 -> .5 .5 [.5,1]
                // Scale 2其实相当于把纹理缩小一倍
                // o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNorm = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 col = tex2D(_MainTex, i.uv).xyz;
                return fixed4(col, 1);
            }

            ENDCG
        }
        
    }
}
