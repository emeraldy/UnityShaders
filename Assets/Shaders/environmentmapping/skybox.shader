Shader "Custom/skybox"
{
    Properties
    {
        //texture
        _Environ("Environment", CUBE) = ""{}
        _InVProjRow0("Inv_Projection_r0", Vector) = (0, 0, 0, 0)
        _InVProjRow1("Inv_Projection_r1", Vector) = (0, 0, 0, 0)
        _InVProjRow2("Inv_Projection_r2", Vector) = (0, 0, 0, 0)
        _InVProjRow3("Inv_Projection_r3", Vector) = (0, 0, 0, 0)
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            samplerCUBE _Environ;

            struct Vertex_Output
            {
                float4 oViewVec : TEXCOORD0;
                float4 oVertPosClip : POSITION0;
            };

            float4 _InVProjRow0;
            float4 _InVProjRow1;
            float4 _InVProjRow2;
            float4 _InVProjRow3;

            Vertex_Output vert(float4 vertPos : POSITION)
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

                float4x4 invProj = {_InVProjRow0.x, _InVProjRow0.y, _InVProjRow0.z, _InVProjRow0.w,
                                    _InVProjRow1.x, _InVProjRow1.y, _InVProjRow1.z, _InVProjRow1.w,
                                    _InVProjRow2.x, _InVProjRow2.y, _InVProjRow2.z, _InVProjRow2.w,
                                    _InVProjRow3.x, _InVProjRow3.y, _InVProjRow3.z, _InVProjRow3.w};

                float4 world = mul(invProj, clip);
                world = mul(UNITY_MATRIX_I_V, world);
                vo.oViewVec = world - float4(_WorldSpaceCameraPos, 1);

                vo.oVertPosClip = clip;

                return vo;
            }

            void frag(float4 viewVec : TEXCOORD0,
                      out float4 oFragColor : COLOR)
            {
                oFragColor = texCUBE(_Environ, normalize(viewVec.xyz));
            }

            ENDCG
        }
    }
}
