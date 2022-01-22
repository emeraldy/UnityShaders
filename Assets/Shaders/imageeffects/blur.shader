Shader "Custom/blur"
{
    Properties
    {
        //texture
        _Scene("Rendered Scene", 2D) = ""{}
        _Resolution("Screen Size", Vector) = (0, 0, 0, 0)
        _Enabled("Enable Blurring", Range(0, 1)) = 1
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _Scene;

            struct Vertex_Output
            {
                float4 oTexCoord : TEXCOORD0;
                float4 oVertPosClip : POSITION0;
            };

            Vertex_Output vert(float4 vertPos : POSITION,
                               float4 texCoord : TEXCOORD0)
            {
                Vertex_Output vo;
                float4x4 S = {2.0f, 0.0f, 0.0f, 0.0f,//row 1
                                0.0f, 2.0f, 0.0f, 0.0f,//row 2
                                0.0f, 0.0f, 1.0f, 0.0f,//row 3
                                0.0f, 0.0f, 0.0f, 1.0f //row 4
                                };

                float4 ndc = mul(S, vertPos);
                //since fsq is the only object in the scene in terms of its corresponding camera, its ndc.z really doesn't matter
                //much, as long as it is within range.
                //to make this shader compatible with both OpenGL and D3D, i set it to 0
                //but maybe due to numerical precision error, exact 0 won't work, hence the value. 
                ndc.z = 0.0000001;

                vo.oTexCoord = texCoord;
                vo.oVertPosClip = ndc;

                return vo;
            }

            float4 _Resolution;
            float _Enabled;

            void frag(float4 texCoord : TEXCOORD0,
                      out float4 oFragColor : COLOR)
            {
                if (_Enabled == 1 && tex2D(_Scene, texCoord).w > 0.5)
                {
                    //essentially, applying a 5x5 gaussian filter
                    float coeff[25] = { 1, 4, 7, 4, 1,
                                        4, 16, 26, 16, 4,
                                        7, 26, 41, 26, 7,
                                        4, 16, 26, 16, 4,
                                        1, 4, 7, 4, 1 };
                    float s = texCoord.x - 2.0 * 1.0 / _Resolution.x;
                    float t = texCoord.y - 2.0 * 1.0 / _Resolution.y;
                    int ci = 0;
                    float4 colour = float4(0, 0, 0, 0);
                    for (int r = 0; r < 5; r++)
                    {
                        for (int c = 0; c < 5; c++)
                        {
                            colour += coeff[ci] * tex2Dlod(_Scene, float4(s, t, 0, 0));//use tex2Dlod to suppress calling-tex2D-in-loop warning
                            ci++;//next coefficient index
                            s += 1.0 / _Resolution.x;//next texel in the row
                        }
                        t += 1.0 / _Resolution.y;//a new row
                        s = texCoord.x - 2.0 * 1.0 / _Resolution.x;//reset to the first texel
                    }
                    oFragColor = colour / 273;
                }
                else
                {
                    oFragColor = tex2D(_Scene, texCoord.xy);
                }
            }

            ENDCG
        }
    }
}
