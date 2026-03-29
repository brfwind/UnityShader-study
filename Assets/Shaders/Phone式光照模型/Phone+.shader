Shader "Study/Phone+"
{
    Properties
    {
        _MainColor("MainColor",Color) = (1,1,1,1)
        _SpecularColor("_SpecularColor",Color) = (1,1,1,1)
        _SpecularNum("_SpecularNum",Range(0,20)) = 5
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;
            fixed4 _SpecularColor;
            float _SpecularNum;

            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 wNormal: NORMAL;
                float3 wPos: TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f data;

                data.pos = UnityObjectToClipPos(v.vertex);
                data.wNormal = UnityObjectToWorldNormal(v.normal);
                data.wPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                
                return data;
            }

            //计算兰伯特光照模型 颜色 函数（传入世界空间的法线）
            fixed3 getLambertFColor(in float3 wNormal)
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                
                fixed3 color = _MainColor.rgb * _LightColor0.rgb * max(0,dot(normalize(wNormal),lightDir));

                return color;
            }

            //计算Phone高光反射模型 颜色 函数（传入世界空间的法线和顶点）
            fixed3 getSpecularFColor(in float3 wNormal,in float3 wPos)
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos - wPos);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 reflectDir = reflect(-lightDir,normalize(wNormal));

                fixed3 color = _SpecularColor.rgb * _LightColor0.rgb * pow(max(0,dot(reflectDir,viewDir)),_SpecularNum);
            
                return color;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 lambertColor = getLambertFColor(i.wNormal);
                fixed3 specularColor = getSpecularFColor(i.wNormal,i.wPos);

                fixed3 color = lambertColor + specularColor + UNITY_LIGHTMODEL_AMBIENT;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}