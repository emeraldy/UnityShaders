Shader "Custom/colour_viewx"
{
    Properties
    {
        _MinX("Min X", float) = 0
        _MaxX("Max X", float) = 0
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            //if you want to return by "out parameters", make sure the minimum output is the last because everything after it is ignored
            void vert(float4 vertPos:POSITION,
                      out float4 oVertPosView : POSITION1,
                      out float4 oVertPosClip : POSITION0)
            {
                oVertPosView = float4(UnityObjectToViewPos(vertPos.xyz), 1.0f);
                oVertPosClip = UnityObjectToClipPos(vertPos.xyz);
            }

            float _MinX;
            float _MaxX;

            void frag(float4 vertPosView : POSITION1,
                      out float4 oFragColor : COLOR)
            {
                float singleChannel = (vertPosView.x - _MinX) / (_MaxX - _MinX);
                oFragColor = float4(singleChannel, 0.0f, 0.0f, 1.0f);
            }

            ENDCG
        }
    }
}