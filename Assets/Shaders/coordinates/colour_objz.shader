Shader "Custom/colour_objz"
{
    Properties
    {
        //make sure to set the scale to 1 when determining the actual coordinate range of the object
        _MinZ("Min Z", float) = 0
        _MaxZ("Max Z", float) = 0
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
                      out float4 oVertPosObj : POSITION1,
                      out float4 oVertPosClip : POSITION0)
            {
                oVertPosObj = vertPos;
                oVertPosClip = UnityObjectToClipPos(vertPos.xyz);
            }

            float _MinZ;
            float _MaxZ;

            void frag(float4 vertPosObj : POSITION1,
                      out float4 oFragColor : COLOR)
            {
                float singleChannel = (vertPosObj.z - _MinZ) / (_MaxZ - _MinZ);
                oFragColor = float4(singleChannel, 0.0f, 0.0f, 1.0f);
            }

            ENDCG
        }
    }
}
