Shader "Unlit/Study"
{
    Properties
    {
        _MyColor("MyColor",Color) = (3,5,0,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert  //顶点着色器
            #pragma fragment frag  //片元着色器

            //在CG语句中，使用ShaderLab里声明的属性
            //声明和属性中对应类型的同名变量即可
            //CG会自动识别并赋值
            fixed4 _MyColor;

            //封装成结构体来实现向顶点着色器中传入更多模型相关信息
            //a2v：用于从应用阶段(a)获取对应语义数据
            //     传给顶点着色器(v)回调函数的
            struct a2v
            {
                float4 vertex:POSITION;  //顶点位置（基于模型空间）
                float3 normal:NORMAL;    //顶点法线（基于模型空间）
                float2 uv:TEXCOORD0;     //纹理坐标
            };

            //v2f：从顶点着色器(v)传递给片元着色器(f)的 结构体数据
            struct v2f
            {
                float4 position:SV_POSITION;  //必备信息（基于裁剪空间）
                float3 normal:NORMAL;    //法线
                float2 uv:TEXCOORD0;     //纹理坐标
            };

            //顶点着色器回调函数
            //POSITION和SV_POSITION是CG语言的语义
            //POSITION：把模型的顶点坐标填充到输入的参数v中
            //SV_POSITION：顶点着色器输出的内容是裁剪空间中的顶点坐标
            //如果没有这些语义来限定输入输出参数的话，渲染器无法知道用户的意思
            v2f vert(a2v data)
            {
                //mul是一个内置函数，矩阵和向量的乘法运算
                //UNITY_MATRIX_MVP，是一个变换矩阵
                //return mul(UNITY_MATRIX_MVP,v);
                v2f v2fData;
                v2fData.position = UnityObjectToClipPos(data.vertex);
                v2fData.normal = data.normal;
                v2fData.uv = data.uv;

                return v2fData;
            }

            //片元着色器回调函数
            //SV_Target：告诉渲染器，把用户输出颜色存储到一个渲染目标中
            fixed4 frag(v2f data):SV_Target
            {
                return _MyColor;
            }
            ENDCG
        }
    }
}
