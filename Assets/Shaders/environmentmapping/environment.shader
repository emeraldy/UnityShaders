Shader "Custom/environment"
{
    Properties
    {
        //texture
        _Environ("Environment", CUBE) = ""{}

        _RefractInd("Refract Index", float) = 1.5 //glass or water
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
                float4 oNorm : TEXCOORD1;
                float4 oCamPosWorld : TEXCOORD0;
                float4 oVertPosWorld : POSITION1;
                float4 oVertPosClip : POSITION0;
            };

            Vertex_Output vert(float4 vertPos : POSITION,
                               float4 normal : NORMAL)
            {
                Vertex_Output vo;

                vo.oCamPosWorld = float4(_WorldSpaceCameraPos, 1);

                //transform normals (obj to world)
                vo.oNorm = mul(transpose(unity_WorldToObject), normal);

                //transform vertices
                vo.oVertPosWorld = mul(unity_ObjectToWorld, vertPos);
                vo.oVertPosClip = UnityObjectToClipPos(vertPos.xyz);

                return vo;
            }

            float _RefractInd;

            void frag(float4 norm : TEXCOORD1,
                      float4 camPosWorld : TEXCOORD0,
                      float4 vertPosView : POSITION1,
                      out float4 oFragColor : COLOR)
            {
                float4 viewVec = camPosWorld - vertPosView;
                float3 reflectVec = reflect(normalize(-viewVec.xyz), normalize(norm.xyz));
                float3 refractVec = refract(normalize(-viewVec.xyz), normalize(norm.xyz), _RefractInd);
                float4 reflectColour = texCUBE(_Environ, reflectVec);
                float4 refractColour = texCUBE(_Environ, refractVec);
                oFragColor = lerp(reflectColour, refractColour, 0.3f);
            }

            ENDCG
        }
    }
}