Shader "Custom/pulsate"
{
    Properties
    {
        _T("Time param", Float) = 0.0
        _Ext("Extent", Float) = 100//bloat extent

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

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _T;
            float _Ext;

            void vert(float4 vertPos : POSITION,
                      float4 norm : NORMAL,
                      out float4 oNorm : TEXCOORD,
                      out float4 oVertPosView : POSITION1,
                      out float4 oVertPosClip : POSITION0)
            {
                //transform normals (obj to view)
                oNorm = mul(UNITY_MATRIX_IT_MV, norm);

                //compute bloating destination
                float3 dest = vertPos.xyz + normalize(norm.xyz) * _Ext;
                float3 currentPos = lerp(vertPos.xyz, dest, _T);

                //transform vertices
                oVertPosView = float4(UnityObjectToViewPos(currentPos), 1);
                oVertPosClip = UnityObjectToClipPos(currentPos);
            }

            float4 _Ambient;
            float4 _Diffuse;
            float4 _Specular;
            float _Shininess;
            float4 _Li_Ambient;
            float4 _Li_Diffuse;
            float4 _Li_Specular;
            float4 _Li_Direction;

            void frag(float4 norm : TEXCOORD,
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

                oFragColor = amb + dif + spe;
            }

            ENDCG
        }
    }
}
