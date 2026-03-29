Shader "Study/HPhone"
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
                fixed3 color: COLOR;
            };

            v2f vert (appdata_base v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);

                float3 normal = UnityObjectToWorldNormal(v.normal);

                //由于我们需要知道从摄像机到被观察的点的 viewDir 向量
                //摄像机坐标可以通过 _WorldSpaceCameraPos 得到
                //被观察的点的位置 需要从模型空间转换到世界空间
                //这里用mul函数，利用内置矩阵运算得到
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //lightDir 指的是从物体指向光源的单位向量
                //但reflect计算，要使用的是入射光（光源指向物体），故需要取负数
                float3 reflectDir = reflect(-lightDir,normal);

                fixed3 color = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(viewDir,reflectDir)),_SpecularNum);

                data.color = color;

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
