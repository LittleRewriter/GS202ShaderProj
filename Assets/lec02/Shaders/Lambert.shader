Shader "GS202/Lesson2/Lambert"
{
    Properties
    {
        _Diffuse ("Diffuse Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 255)) = 32
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwd_base

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            fixed _Gloss;

            struct v2f {
                fixed4 pos : SV_POSITION;
                fixed3 normal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 light = normalize(_WorldSpaceLightPos0.xyz);
                // 平行光 (lightDir, 0)
                // 非平行光 (lightPos, 1)
                fixed3 diffuse = _Diffuse.rgb * saturate(dot(light, normalize(i.normal)));
                // saturate(x)  把x限制到[0,1]
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                // n · h, h = ||viewDir + lightDir||
                fixed3 halfVec = normalize(viewDir + light);
                fixed3 specular = _Specular.rgb * pow(saturate(dot(halfVec, normalize(i.normal))), _Gloss);
                return fixed4(diffuse + ambient + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
