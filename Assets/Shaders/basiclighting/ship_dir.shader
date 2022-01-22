Shader "Custom/ship_dir"
{
    Properties
    {
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

    //directional lighting using phong model, computed in view space
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertOutput
            {
                float4 oNorm : TEXCOORD;
                float4 oVertPosView : POSITION1;
                float4 oVertPosClip : POSITION0;
            };

            VertOutput vert(float4 vertPos : POSITION,
                            float4 norm : NORMAL)
            {
                VertOutput vo;
                //transform normals (obj to view)
                vo.oNorm = mul(UNITY_MATRIX_IT_MV, norm);

                //transform vertices
                vo.oVertPosView = float4(UnityObjectToViewPos(vertPos.xyz), 1);
                vo.oVertPosClip = UnityObjectToClipPos(vertPos.xyz);

                return vo;
            }

            //uniforms from host
            float4 _Ambient;
            float4 _Diffuse;
            float4 _Specular;
            float _Shininess;
            float4 _Li_Ambient;
            float4 _Li_Diffuse;
            float4 _Li_Specular;
            float4 _Li_Direction;

            void frag(VertOutput vo, out float4 oFragColor : COLOR)
            {
                //ambient
                float4 amb = _Ambient * _Li_Ambient;

                //diffuse
                float3 n = normalize(vo.oNorm.xyz);
                float ndotl = max(0, dot(normalize(-_Li_Direction.xyz), n));
                float4 dif = _Diffuse * _Li_Diffuse * ndotl;

                //specular
                float3 r = reflect(normalize(_Li_Direction.xyz), n);
                float rdotv = max(0, dot(normalize(-vo.oVertPosView.xyz), normalize(r)));
                if (ndotl == 0)
                    rdotv = 0;
                float4 spe = _Specular * _Li_Specular * pow(rdotv, _Shininess);

                oFragColor = amb + dif + spe;
            }

            ENDCG
        }
    }
}
