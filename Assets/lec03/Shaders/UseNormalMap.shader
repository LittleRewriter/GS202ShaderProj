Shader "GS202/Lesson3/UseNormalMap"
{
    Properties {
        _MainTex("Main Texture", 2D) = "white" {}
        _Diffuse("Diffuse Color", Color) = (1,1,1,1)
        _AOTex("Ambient Occlusion", 2D) = "white" {}
        _Specular("Specular Color", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(10, 100)) = 32
        // 完全不凸，默认值是蓝色的。所以法线贴图默认是bump
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
                float3 worldNorm : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldT : TEXCOORD3;
                float3 worldB : TEXCOORD4;
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
                o.worldNorm = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldT = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldB = cross(o.worldNorm, o.worldT) * v.tangent.w;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                // Bump
                half4 packedNorm = tex2D(_NormalMap, i.uv);
                // 法线 [-1,1] 从[0,1]变换 -> (n - .5) * 2
                // UnpackNormal 乘上一个系数
                half3 unpackedNormal = UnpackNormal(packedNorm) * _BumpScale;
                unpackedNormal.z = sqrt(1 - saturate(dot(unpackedNormal.xy, unpackedNormal.xy)));
                half3 worldNormal = normalize(mul(unpackedNormal, float3x3(i.worldT, i.worldB, i.worldNorm)));
                // 采样
                fixed3 col = tex2D(_MainTex, i.uv).xyz;
                // lambert
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 diffuse = _Diffuse * (.5*dot(lightDir, worldNormal)+.5);
                diffuse *= col;
                // ambient
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed aoRatio = tex2D(_AOTex, i.uv).x;
                ambient *= aoRatio;
                // specular
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 hVec = normalize(lightDir + viewDir);
                half3 spec = _Specular * pow(max(0, dot(hVec, worldNormal)), _Gloss);
                // specular occlusion
                spec *= aoRatio;
                return fixed4(diffuse + ambient + spec, 1);
            }

            ENDCG
        }
        
    }
}
