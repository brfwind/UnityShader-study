Shader "Study/Lambert"
{
    Properties
    {
        //材质的漫反射光照颜色
        _MainColor ("MainColor", Color) =  (1, 1, 1, 1)
    }
    SubShader
    {
        //向前渲染的光照模式，主要用于处理不透明物体的光照渲染
        Tags { "LightMode" = "ForwardBase" }     //固定光照模式

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"    //包含坐标空间转换方法
            #include "Lighting.cginc"   //包含光照相关信息

            fixed4 _MainColor;    //材质的漫反射颜色

            //顶点着色器传递给片元着色器的内容
            struct v2f
            {
                float4 pos : SV_POSITION;     //裁剪空间下的顶点坐标信息
                fixed3 color : COLOR;         //对应顶点的漫反射光照颜色
            };

            //逐顶点光照：主要计算写在顶点着色器回调函数中
            v2f vert(appdata_base v)
            {
                //声明供返回的v2f变量
                v2f v2fData;
                //把模型空间下的顶点 转换到裁剪空间下
                v2fData.pos = UnityObjectToClipPos(v.vertex);

                //光照颜色：_LightColor0
                //光源在世界坐标下的位置：_WorldSpaceLightPos0
                //模型空间下的法线：v.normal
                float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //有相关参数后，用公式计算
                fixed3 color = _LightColor0.rgb * _MainColor.rgb * max(0, dot(normal, lightDir));

                //记录颜色，用以传给片元着色器
                //color还加了个兰伯特光照模型环境光变量
                v2fData.color = color + UNITY_LIGHTMODEL_AMBIENT;

                //注：使用xyz和rgb，是因为兰伯特光照模型不考虑透明物体，故不需要四维加上Alpha信息
                return v2fData;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //把计算好的兰伯特光照颜色传递出去
                return fixed4(i.color.rgb, 1);
            }
            ENDCG
        }
    }
}