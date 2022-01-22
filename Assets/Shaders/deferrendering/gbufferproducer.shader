/*for MRT in Unity, remember to set Rendering Path of cameras which use this shader to Forward.
otherwise, colour buffers other than index 0 will not get cleared before rendering the next frame.*/
Shader "Custom/gbufferproducer"
{
    Properties
    {
        //g buffers
        _GB_Diff("Diffuse (Gbuffer)", 2D) = "" {}
        _GB_Spec("Specular (Gbuffer)", 2D) = "" {}
        _GB_Colo("Colour Texture (Gbuffer)", 2D) = "" {}

        //object texture
        _Texture("Texture", 2D) = "" {}

        //light source
        _Li_Ambient("Light ambient", Color) = (0.1, 0.1, 0.1, 0.1)
        _Li_Diffuse("Light diffuse", Color) = (0.1, 0.1, 0.1, 0.1)
        _Li_Specular("Light specular", Color) = (0.1, 0.1, 0.1, 0.1)
        _Li_Direction("Light direction", Vector) = (0, -1, 0, 0)//in view space (host script makes sure of it)

        //material
        _Ambient("Ambient", Color) = (0.1, 0.1, 0.1, 0.1)
        _Diffuse("Diffuse", Color) = (0.1, 0.1, 0.1, 0.1)
        _Specular("Specular", Color) = (0.1, 0.1, 0.1, 0.1)
        _Shininess("Shininess", Float) = 25.0
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
            sampler2D _Texture;

            void vert(float4 vertPos : POSITION,
                      float4 norm : NORMAL,
                      float4 texCoord : TEXCOORD0,
                      out float4 oTexCoord : TEXCOORD0,
                      out float4 oNorm : TEXCOORD1,
                      out float4 oVertPosView : POSITION1,
                      out float4 oVertPosClip : POSITION0)
            {
                //transform normals (obj to view)
                oNorm = mul(UNITY_MATRIX_IT_MV, norm);

                oTexCoord = texCoord;

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

            void frag(float4 texCoord : TEXCOORD0,
                      float4 norm : TEXCOORD1,
                      float4 vertPosView : POSITION1,
                      out float4 oColo : COLOR2,
                      out float4 oSpec : COLOR1,
                      out float4 oDiff : COLOR0)
            {
                //diffuse
                float3 n = normalize(norm.xyz);
                float ndotl = max(0, dot(normalize(-_Li_Direction.xyz), n));

                //specular
                float3 r = reflect(normalize(_Li_Direction.xyz), n);
                float rdotv = max(0, dot(normalize(-vertPosView.xyz), normalize(r)));
                if (ndotl == 0)
                    rdotv = 0;

                //colour from texture (ambient included)
                oColo = 0.4 * tex2D(_Texture, texCoord.xy) + _Ambient * _Li_Ambient;

                oSpec = _Specular * _Li_Specular * pow(rdotv, _Shininess);
                oDiff = _Diffuse * _Li_Diffuse * ndotl;
                oDiff.w = 1;//flag for scene object so we can fill the background with its own colour
            }

            float4 floatToRGBA(float v) {
                float4 enc = float4(1.0, 255.0, 65025.0, 16581375.0) * v;
                enc = frac(enc);
                enc -= enc.yzww * float4(1.0 / 255.0, 1.0 / 255.0, 1.0 / 255.0, 0.0);
                return enc;
            }

            float RGBAToFloat(float4 rgba) {
                return dot(rgba, float4(1.0, 1 / 255.0, 1 / 65025.0, 1 / 16581375.0));
            }

            ENDCG
        }
    }
}
