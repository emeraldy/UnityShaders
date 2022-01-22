Shader "Custom/daynight"
{
    Properties
    {
        _T("Time param", Float) = 0.0
        _Day("Day", 2D) = "" {}
        _Night("Night", 2D) = "" {}
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _Day;
            sampler2D _Night;

            void vert(float4 vertPos : POSITION,
                      float4 texCoord : TEXCOORD0,
                      out float4 oTexCoord : TEXCOORD0,
                      out float4 oVertPosClip : POSITION)
            {

                oTexCoord = texCoord;
                oVertPosClip = UnityObjectToClipPos(vertPos);
            }

            float _T;

            void frag(float4 texCoord : TEXCOORD0,
                      out float4 oFragColor : COLOR)
            {
                oFragColor = lerp(tex2D(_Day, texCoord.xy), tex2D(_Night, texCoord.xy), _T);
            }

            ENDCG
        }
    }
}
