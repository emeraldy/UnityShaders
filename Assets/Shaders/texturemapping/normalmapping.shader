Shader "Custom/normalmapping"
{
    Properties
    {
        //texture
        _Colour("Colour", 2D) = ""{}
        _Normal("Normal", 2D) = ""{}

        //material
        _Ambient("Ambient", Color) = (0.1, 0.1, 0.1, 0.1)
        _Diffuse("Diffuse", Color) = (0.1, 0.1, 0.1, 0.1)
        _Specular("Specular", Color) = (0.1, 0.1, 0.1, 0.1)
        _Shininess("Shininess", Float) = 25.0

        //light source
        _Li_Ambient("Light ambient", Color) = (0.1, 0.1, 0.1, 0.1)
        _Li_Diffuse("Light diffuse", Color) = (0.1, 0.1, 0.1, 0.1)
        _Li_Specular("Light specular", Color) = (0.1, 0.1, 0.1, 0.1)
        _Li_Direction("Light direction", Vector) = (0, -1, 0, 0)//in view space (host script makes sure of it)
    }

    //two light sources are used here: one for bumpy effect only (denoted bumpy light) 
    //while the other one for the actual directional lighting in the scene
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _Colour;
            sampler2D _Normal;

            struct Vertex_Output
            {
                float4 oTexCoord : TEXCOORD0;
                float4 oNorm : TEXCOORD1;
                float4 oTangent : TEXCOORD2;
                float4 oVertPosView : POSITION1;
                float4 oVertPosClip : POSITION0;
            };

            Vertex_Output vert(float4 vertPos : POSITION,
                               float4 tangent : TANGENT,
                               float4 texCoord : TEXCOORD0,
                               float4 normal : NORMAL)
            {
                Vertex_Output vo;

                vo.oTexCoord = texCoord;

                //transform normals, tangents and direction of the bumpy light (obj to view)
                vo.oNorm = mul(UNITY_MATRIX_IT_MV, normal);
                vo.oTangent = mul(UNITY_MATRIX_MV, float4(tangent.xyz, 0.0f));
                vo.oTangent.w = tangent.w;

                //transform vertices
                vo.oVertPosView = float4(UnityObjectToViewPos(vertPos.xyz), 1);
                vo.oVertPosClip = UnityObjectToClipPos(vertPos.xyz);

                return vo;
            }

            float4 _Ambient;
            float4 _Diffuse;
            float4 _Specular;
            float _Shininess;
            float4 _Li_Ambient;
            float4 _Li_Diffuse;
            float4 _Li_Specular;
            float4 _Li_Direction;//of the actual scene light (in view space already)

            void frag(float4 texCoord : TEXCOORD0,
                      float4 norm : TEXCOORD1,
                      float4 tangent : TEXCOORD2,
                      float4 vertPosView : POSITION1,
                      out float4 oFragColor : COLOR)
            {
                //ambient
                float4 amb = _Ambient * _Li_Ambient;

                //diffuse
                //construct transformation from view (where light direction is described) to tangent
                float3 n = normalize(norm.xyz);
                float3 tan = normalize(tangent.xyz);
                float3 bi = normalize(cross(n, tan) * tangent.w);

                float4x4 T = {1.0f, 0.0f, 0.0f, -vertPosView.x,//row 1
                                0.0f, 1.0f, 0.0f, -vertPosView.y,//row 2
                                0.0f, 0.0f, 1.0f, -vertPosView.z,//row 3
                                0.0f, 0.0f, 0.0f, 1.0f           //row 4
                                };

                float4x4 R = {tan.x, tan.y, tan.z, 0.0f,//row 1
                                bi.x, bi.y, bi.z, 0.0f,   //row 2
                                n.x, n.y, n.z, 0.0f,      //row 3
                                0.0f, 0.0f, 0.0f, 1.0f    //row 4
                                };

                float4x4 viewToTan = mul(R, T);

                //transform direction of the bumpy light (obj to view)
                //bumpy light always shines straight down
                float4 bLightdir_tan = mul(UNITY_MATRIX_MV, float4(00.0f, -1.0f, 0.0f, 0.0f));

                //tranform direction fo the bumpy light (view to tangent)
                bLightdir_tan = mul(viewToTan, bLightdir_tan);

                //diffuse component of the bumpy light and its corresponding material component
                float4 bLight_dif = float4(0.73f, 0.73f, 0.73f, 0.0f);
                float4 bLightMat_dif = float4(1.0f, 1.0f, 1.0f, 0.0f);
                float4 storedNormal = tex2D(_Normal, texCoord.xy) * 2.0f - 1.0f;//sample from normal map and decode
                float ndotl = max(0, dot(normalize(-bLightdir_tan.xyz), normalize(storedNormal.xyz)));
                float4 bumpyDif = bLight_dif * bLightMat_dif * ndotl;

                float trueNdotl = max(0, dot(normalize(-_Li_Direction.xyz), n));
                //float4 dif = _Diffuse * _Li_Diffuse * trueNdotl;//no need for this calculation

                //specular
                float3 r = reflect(normalize(_Li_Direction.xyz), n.xyz);
                float rdotv = max(0, dot(normalize(-vertPosView.xyz), normalize(r)));
                float4 spe = _Specular * _Li_Specular * pow(rdotv, _Shininess);

                //will not add specular term here since the barrel is meant to be tarnished
                //otherwise can just add the term inside the bracket
                oFragColor = amb + (bumpyDif + tex2D(_Colour, texCoord.xy)) * trueNdotl;
            }

            ENDCG
        }
    }
}
