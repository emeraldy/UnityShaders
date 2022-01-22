Shader "Custom/motionblur"
{
    Properties
    {
        //texture
        _Scene("Rendered Scene", 2D) = ""{}
        _Resolution("Screen Size", Vector) = (0, 0, 0, 0)
        _BlurDirection("Blur Direction", Vector) = (-8, 4, 0, 0)
        _BlurSamples("Blur Samples", float) = 25
        _BlurDistance("Blur Distance", float) = 80
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
            float4 _BlurDirection;
            float _BlurSamples;
            float _BlurDistance;

            void frag(float4 texCoord : TEXCOORD0,
                      out float4 oFragColor : COLOR)
            {
                float4 color = float4(0, 0, 0, 0);
                float2 dir = normalize(float2(_BlurDirection.x, _BlurDirection.y));
                float stepLength = _BlurDistance / _BlurSamples;

                //sampling based on equal distance on s axis
                float deltaS, deltaT;
                for (int i = 0; i < _BlurSamples; i++)
                {
                    deltaS = i * (stepLength * 1.0 / _Resolution.x) * dir.x;
                    deltaT = i * (stepLength * 1.0 / _Resolution.y) * dir.y;
                    color += tex2D(_Scene, texCoord.xy + float2(deltaS, deltaT));
                }
                oFragColor = color / _BlurSamples;
            }

            ENDCG
        }
    }
}
