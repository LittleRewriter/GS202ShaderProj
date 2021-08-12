Shader "GS202/Lesson3/UseAOTex"
{
    Properties {
        _MainTex("Main Texture", 2D) = "white" {}
        _Diffuse("Diffuse Color", Color) = (1,1,1,1)
        _AOTex("Ambient Occlusion", 2D) = "white" {}
        _Specular("Specular Color", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(10, 100)) = 32
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
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            // S:scale T:translate
            float4 _MainTex_ST;
            sampler2D _AOTex;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert(appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNorm = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                // 采样
                fixed3 col = tex2D(_MainTex, i.uv).xyz;
                // lambert
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 diffuse = _Diffuse * (.5*dot(lightDir, i.worldNorm)+.5);
                diffuse *= col;
                // ambient
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed aoRatio = tex2D(_AOTex, i.uv).x;
                ambient *= aoRatio;
                // specular
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 hVec = normalize(lightDir + viewDir);
                half3 spec = _Specular * pow(max(0, dot(hVec, i.worldNorm)), _Gloss);
                // specular occlusion
                spec *= aoRatio;
                return fixed4(diffuse + ambient + spec, 1);
            }

            ENDCG
        }
        
    }
}
