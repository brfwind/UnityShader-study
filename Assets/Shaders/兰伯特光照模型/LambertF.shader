Shader "Study/LambertF"
{
    //和逐顶点的区别在于
    //1.在顶点着色器中计算顶点和法线
    //2.在片元着色器中计算兰伯特光照

    Properties
    {
        _MainColor("MainColor",Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _MainColor;

            //结构体根据需求做更改
            //现在需求是需要向片元着色器传法向量信息
            struct v2f
            {
                float4 pos:SV_POSITION;
                fixed3 normal:NORMAL;
            };

            //这里的顶点着色器只负责计算法向量以及顶点坐标转换
            v2f vert (appdata_base v)
            {
                v2f v2fData;
                v2fData.pos = UnityObjectToClipPos(v.vertex);

                float3 normal = UnityObjectToWorldNormal(v.normal);
                v2fData.normal = normal;

                return v2fData;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //在片元着色器里计算光照方向
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 color = _LightColor0.rgb * _MainColor.rgb * max(0,dot(i.normal,lightDir));
                color = color + UNITY_LIGHTMODEL_AMBIENT;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
