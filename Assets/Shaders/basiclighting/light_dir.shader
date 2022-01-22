Shader "Custom/light_dir"
{
    Properties
    {
        _Ambient("Ambient", Color) = (0.1, 0.1, 0.1, 0.1)
        _Diffuse("Diffuse", Color) = (0.1, 0.1, 0.1, 0.1)
        _Specular("Specular", Color) = (0.1, 0.1, 0.1, 0.1)
    }

    //a simple shader pretending light emission
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            void vert(float4 vertPos:POSITION,
                      out float4 oVertPosClip : POSITION0)
            {
                oVertPosClip = UnityObjectToClipPos(vertPos.xyz);
            }

            //uniforms from host
            float4 _Ambient;
            float4 _Diffuse;
            float4 _Specular;

            void frag(out float4 oFragColor : COLOR)
            {
                oFragColor = (_Ambient + _Diffuse + _Specular) / 3;
            }

            ENDCG
        }
    }
}
