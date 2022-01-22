Shader "Custom/checkerboard"
{
    Properties
    {
        _Phase("Phase", Vector) = (0, 0, 0, 0)
        _Freq("Frequency", Vector) = (5.7, -6.3, 0, 0)
        _Amp("Amplitude", Vector) = (0.08, 0.06, 0, 0)
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Vertex_Output
            {
                float4 oTexCoord : TEXCOORD0;
                float4 oVertPosClip : POSITION0;
            };

            Vertex_Output vert(float4 vertPos : POSITION,
                               float4 texCoord : TEXCOORD0)
            {
                Vertex_Output vo;

                vo.oTexCoord = texCoord;

                vo.oVertPosClip = UnityObjectToClipPos(vertPos.xyz);

                return vo;
            }

            float4 _Phase;
            float4 _Freq;
            float4 _Amp;

            void frag(float4 texCoord : TEXCOORD0,
                      out float4 oFragColor : COLOR)
            {
                float2 perturbTexCoord;
                perturbTexCoord.x = _Amp.x * sin((texCoord.x + texCoord.y) * _Freq.x + _Phase.x) + texCoord.x;
                perturbTexCoord.y = _Amp.y * sin((texCoord.x + texCoord.y) * _Freq.y + _Phase.y) + texCoord.y;

                //extract the first digit of the decimal part of texCoord 
                int s_int, t_int;
                modf(perturbTexCoord.x * 10, s_int);
                modf(perturbTexCoord.y * 10, t_int);

                //odd or even
                if (fmod(s_int, 2) == fmod(t_int, 2))
                    oFragColor = float4(0, 0, 0, 0);
                else
                    oFragColor = float4(1, 1, 1, 1);
            }

            ENDCG
        }
    }
}
