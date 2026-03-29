Shader "Study/HBlinn-Phone"
{
    Properties
    {
        _SpecularColor("SpecularColoe",Color) = (1,1,1,1)
        _SpecularNum("SpecularNum",Range(0,20)) = 5
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
                float4 pos:SV_POSITION;
                fixed3 color: COLOR;
            };


            v2f vert (appdata_base v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - wPos);
                float3 halfA = normalize(lightDir + viewDir);

                data.color = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(wNormal,halfA)),_SpecularNum);

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
