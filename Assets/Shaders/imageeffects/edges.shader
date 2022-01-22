Shader "Custom/edges"
{
    Properties
    {
        //texture
        _Scene("Rendered Scene", 2D) = ""{}
        _Resolution("Screen Size", Vector) = (0, 0, 0, 0)
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
                //since d3d reverses z depth, skybox plane needs to be at z=0 (farthest in the scene).
                //but maybe for numerical precision error, exact 0 won't work, hence the value.
                ndc.z = 0.000000001;

                //let p be the projection matrix
                //since clipz = p.33 * eyez + p.34 and ndc.z = clipz / w and w = p.43 * eyez and ndc.z = 0 in this case,
                //solve w as follows:
                float w = UNITY_MATRIX_P._43 * (-UNITY_MATRIX_P._34 / UNITY_MATRIX_P._33);
                float4 clip = ndc * w;

                vo.oTexCoord = texCoord;
                vo.oVertPosClip = clip;

                return vo;
            }

            float4 _Resolution;

            void frag(float4 texCoord : TEXCOORD0,
                      out float4 oFragColor : COLOR)
            {
                float2 offset_left = float2(-1.0 / _Resolution.x, 0.0);
                float2 offset_right = float2(1.0 / _Resolution.x, 0.0);
                float4 Color_Left = tex2D(_Scene, texCoord.xy + offset_left);
                float4 Color_Right = tex2D(_Scene, texCoord.xy + offset_right);
                oFragColor = abs(Color_Right - Color_Left) * 5.0;
            }

            ENDCG
        }
    }
}
