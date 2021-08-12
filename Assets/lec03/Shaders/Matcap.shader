Shader "GS202/Lesson3/Matcap"
{
    Properties {
        _NormalMap("Normal Map", 2D) = "bump" {}   
        _BumpScale("Bump Scale", Float) = 1.0
        _Matcap("Matcap", 2D) = "white" {}
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

            sampler2D _NormalMap;
            float _BumpScale;
            sampler2D _Matcap;


            v2f vert(appdata_full v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
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
                worldNormal = worldNormal / 2 + .5;
                fixed3 color = tex2D(_Matcap, worldNormal.xy);
                return fixed4(color, 1);
            }

            ENDCG
        }
        
    }
}
