Shader "GS202/Lesson3/UseNormalMapTangentSpace"
{
    Properties {
        _MainTex("Main Texture", 2D) = "white" {}
        _Diffuse("Diffuse Color", Color) = (1,1,1,1)
        _AOTex("Ambient Occlusion", 2D) = "white" {}
        _Specular("Specular Color", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(10, 100)) = 32
        _NormalMap("Normal Map", 2D) = "bump" {}   
        _BumpScale("Bump Scale", Float) = 1.0
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
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            // S:scale T:translate
            float4 _MainTex_ST;
            sampler2D _AOTex;
            sampler2D _NormalMap;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            float _BumpScale;


            v2f vert(appdata_full v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                TANGENT_SPACE_ROTATION;
                // Unity宏，产生rotation矩阵，用来做TBN变换
                o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
                o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                // Bump
                half4 packedNorm = tex2D(_NormalMap, i.uv);
                // 法线 [-1,1] 从[0,1]变换 -> (n - .5) * 2
                // UnpackNormal 乘上一个系数
                half3 unpackedNormal = UnpackNormal(packedNorm) * _BumpScale;
                unpackedNormal.z = sqrt(1 - saturate(dot(unpackedNormal.xy, unpackedNormal.xy)));
                // 采样
                fixed3 col = tex2D(_MainTex, i.uv).xyz;
                // lambert
                float3 diffuse = _Diffuse * (.5*dot(i.lightDir, unpackedNormal)+.5);
                diffuse *= col;
                // ambient
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed aoRatio = tex2D(_AOTex, i.uv).x;
                ambient *= aoRatio;
                // specular
                half3 hVec = normalize(i.lightDir + i.viewDir);
                half3 spec = _Specular * pow(max(0, dot(hVec, unpackedNormal)), _Gloss);
                // specular occlusion
                spec *= aoRatio;
                return fixed4(diffuse + ambient + spec, 1);
            }

            ENDCG
        }
        
    }
}
