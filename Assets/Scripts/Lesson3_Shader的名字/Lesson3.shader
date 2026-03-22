Shader "TeachShader/Lesson3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        //格式中 最重要的是类型 其他的是名字和默认值

        //数值类型属性
        _MyFLoat("MyFloat",float) = 1.5
        _MyRange("MyRange",Range(0,5)) = 0
        
        //颜色和向量类型属性（都由四个分量代表）
        _MyColor("MyColor",Color) = (0.5,0.5,0.5,1)
        _MyVector("MyVector",Vector) = (99,95,98,12)

        //纹理贴图类型属性(常用的两种)
        _My2D("My2D",2D) = ""{}
        _MyCude("MyCube",Cube) = ""{}

    }

    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
            "Queue"="Background"
             }
             
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
