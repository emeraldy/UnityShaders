Shader "Custom/colour_screeny"
{
    Properties
    {
        _MinY("Min Y", float) = 0
        _MaxY("Max Y", float) = 0
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
                      out float4 oVertPosClip : POSITION)
            {
                oVertPosClip = UnityObjectToClipPos(vertPos.xyz);
            }

            float _MinY;
            float _MaxY;

            void frag(float4 vertPosScreen : POSITION,//fragment coordinates now
                      out float4 oFragColor : COLOR)
            {
                float singleChannel = (vertPosScreen.y - _MinY) / (_MaxY - _MinY);
                oFragColor = float4(singleChannel, 0.0f, 0.0f, 1.0f);
            }

            ENDCG
        }
    }
}
