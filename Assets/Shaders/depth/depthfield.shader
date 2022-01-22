Shader "Custom/depthfield"
{
    Properties
    {
        //colour texture
        _MainTexture("Color texture", 2D) = "" {}

        //camera z range
        _MinFocal("Min focal length", Float) = 0.5
        _MaxFocal("Max focal length", Float) = 1

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

            sampler2D _MainTexture;

            void vert(float4 vertPos : POSITION,
                      float4 norm : NORMAL,
                      float4 texCoord : TEXCOORD0,
                      out float4 oTexCoord : TEXCOORD0,
                      out float4 oNorm : TEXCOORD1,
                      out float4 oVertPosView : POSITION1,
                      out float4 oVertPosClip : POSITION0)
            {
                oTexCoord = texCoord;

                //transform normals (obj to view)
                oNorm = mul(UNITY_MATRIX_IT_MV, norm);

                //transform vertices
                oVertPosView = float4(UnityObjectToViewPos(vertPos.xyz), 1);
                oVertPosClip = UnityObjectToClipPos(vertPos.xyz);
            }

            float4 _Ambient;
            float4 _Diffuse;
            float4 _Specular;
            float _Shininess;
            float4 _Li_Ambient;
            float4 _Li_Diffuse;
            float4 _Li_Specular;
            float4 _Li_Direction;
            float _MinFocal;
            float _MaxFocal;

            void frag(float4 texCoord : TEXCOORD0,
                      float4 norm : TEXCOORD1,
                      float4 vertPosView : POSITION1,
                      out float4 oFragColor : COLOR)
            {
                //ambient
                float4 amb = _Ambient * _Li_Ambient;

                //diffuse
                float3 n = normalize(norm.xyz);
                float ndotl = max(0, dot(normalize(-_Li_Direction.xyz), n));
                float4 dif = _Diffuse * _Li_Diffuse * ndotl;

                //specular
                float3 r = reflect(normalize(_Li_Direction.xyz), n);
                float rdotv = max(0, dot(normalize(-vertPosView.xyz), normalize(r)));
                if (ndotl == 0)
                    rdotv = 0;
                float4 spe = _Specular * _Li_Specular * pow(rdotv, _Shininess);

                //colour texture
                float4 colourTex = tex2D(_MainTexture, texCoord.xy);
                colourTex += amb + dif + spe;
                //blur flag (stored in alpha)
                if (-vertPosView.z < _MinFocal || -vertPosView.z > _MaxFocal)
                {
                    colourTex.w = 1;
                }
                else
                {
                    colourTex.w = 0;
                }
                oFragColor = colourTex;
            }

            ENDCG
        }
    }
}
