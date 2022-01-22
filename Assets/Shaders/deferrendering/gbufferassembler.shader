Shader "Custom/gbufferassembler"
{
    Properties
    {
        //g buffers
        _GB_Diff("Diffuse (Gbuffer)", 2D) = "" {}
        _GB_Spec("Specular (Gbuffer)", 2D) = "" {}
        _GB_Colo("Colour Texture (Gbuffer)", 2D) = "" {}
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _GB_Diff;
            sampler2D _GB_Spec;
            sampler2D _GB_Colo;

            struct Vertex_Output
            {
                float4 oTexCoord : TEXCOORD0;
                float4 oVertPosClip : POSITION0;
            };

            Vertex_Output vert(float4 vertPos : POSITION,
                               float4 texCoord : TEXCOORD0)
            {
                Vertex_Output vo;
                float4x4 S = { 2.0f, 0.0f, 0.0f, 0.0f,//row 1
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

            void frag(float4 texCoord : TEXCOORD0,
                      out float4 oFragColor : COLOR)
            {
                if (tex2D(_GB_Diff, texCoord.xy).w < 1)
                    oFragColor = float4(0.07f, 0.645f, 0.93f, 0);//background colour
                else
                    oFragColor = tex2D(_GB_Colo, texCoord.xy) + tex2D(_GB_Diff, texCoord.xy) + tex2D(_GB_Spec, texCoord.xy);
            }

            ENDCG
        }
    }
}
