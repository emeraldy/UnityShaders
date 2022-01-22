Shader "Custom/sharpen"
{
    Properties
    {
        //texture
        _Scene("Rendered Scene", 2D) = ""{}
        _Resolution("Screen Size", Vector) = (0, 0, 0, 0)
        _Enabled("Enable Sharpening", Range(0, 1)) = 1
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
            float _Enabled;

            void frag(float4 texCoord : TEXCOORD0,
                      out float4 oFragColor : COLOR)
            {
                if (_Enabled == 1)
                {
                    //essentially, a laplacian filter
                    float2 north = float2(0.0, 1.0 / _Resolution.y);
                    float2 west = float2(-1.0 / _Resolution.x, 0.0);
                    float2 east = float2(1.0 / _Resolution.x, 0.0);
                    float2 south = float2(0.0, -1.0 / _Resolution.y);

                    float4 Color_North = tex2D(_Scene, texCoord.xy + north);
                    float4 Color_West = tex2D(_Scene, texCoord.xy + west);
                    float4 Color_East = tex2D(_Scene, texCoord.xy + east);
                    float4 Color_South = tex2D(_Scene, texCoord.xy + south);
                    float4 Color_Centre = tex2D(_Scene, texCoord.xy);
                    float4 Color = Color_North + Color_West + Color_East + Color_South - 4.0 * Color_Centre;
                    oFragColor = Color_Centre - Color;
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
