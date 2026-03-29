Shader "Study/Phone"
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
                fixed3 color: COLOR;
            };

            //计算兰伯特光照模型 颜色 函数（传入模型空间的法向量）
            fixed3 getLambertColor(in float3 objNormal)
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 wNormal = normalize(UnityObjectToWorldNormal(objNormal));
                
                fixed3 color = _MainColor.rgb * _LightColor0.rgb * max(0,dot(wNormal,lightDir));

                return color;
            }

            //计算Phone高光反射模型 颜色 函数（传入模型空间的法向量和顶点）
            fixed3 getSpecularColor(in float3 objNormal,in float4 objVertex)
            {
                float3 wPos = mul(unity_ObjectToWorld,objVertex).xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - wPos);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 wNormal = normalize(UnityObjectToWorldNormal(objNormal));
                float3 reflectDir = reflect(-lightDir,wNormal);

                fixed3 color = _SpecularColor.rgb * _LightColor0.rgb * pow(max(0,dot(reflectDir,viewDir)),_SpecularNum);
            
                return color;
            }

            v2f vert (appdata_base v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);

                fixed3 lambertColor = getLambertColor(v.normal);
                fixed3 specularColor = getSpecularColor(v.normal,v.vertex);

                data.color = lambertColor + specularColor + UNITY_LIGHTMODEL_AMBIENT;
                return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color,1);
            }
            ENDCG
        }
    }
}
