Shader "Study/HPhone+"
{
    Properties
    {
        _SpecularColor("_SpecularColor",Color) = (1,1,1,1)  //材质高光反射颜色
        _SpecularNum("_SpecularNum",Range(0,20)) = 0.5  //光泽度指数
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

            fixed4 _SpecularColor;
            float _SpecularNum;

            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 wPos: TEXCOORD0;
                float3 wNormal: NORMAL;
            };

            v2f vert (appdata_base v)
            {
                v2f data;
                //裁剪空间变换
                data.pos = UnityObjectToClipPos(v.vertex);

                //法线空间变换
                data.wNormal = UnityObjectToWorldNormal(v.normal);
                 
                //顶点转世界空间
                data.wPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                return data; 
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.wPos);

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 reflectDir = reflect(-lightDir,normalize(i.wNormal));

                fixed3 color = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(viewDir,reflectDir)),_SpecularNum);
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
