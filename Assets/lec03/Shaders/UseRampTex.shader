Shader "GS202/Lesson3/UseRampTex"
{
    Properties{
        _Diffuse ("Diffuse Color, k_d", Color) = (1, 1, 1, 1)
        _RampTex("Main Texture", 2D) = "white" {}
    }

    SubShader {
        Pass {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            sampler2D _RampTex;

            struct v2f {
                float4 pos : SV_POSITION;
                half3 normal : TEXCOORD0;
                half2 uv : TEXCOORD1;
            };

            #pragma vertex vert
            #pragma fragment frag

            v2f vert(appdata_base i) {
                v2f v;
                v.pos = UnityObjectToClipPos(i.vertex);
                v.uv = i.vertex;
                v.normal = UnityObjectToWorldNormal(i.normal);
                return v;
            }

            fixed4 frag(v2f v) : SV_TARGET {
                half light = normalize(_WorldSpaceLightPos0.xyz);
                half diffuse = 0.5 * dot(light, v.normal) + 0.5;
                fixed3 rampColor = tex2D(_RampTex, float2(diffuse, .5)).xyz;
                return fixed4(rampColor, 1);
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}
