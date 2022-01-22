Shader "Custom/wavy"
{
    Properties
    {
        _T("Time param", Float) = 0.0
        _WaveDirection("Wave direction", Vector) = (120.0, 0.0, 240.0, 0.0)
        _Frequency("Frequency", Vector) = (20.0, 10.0, 15.0, 0.0)
        _Amplitude("Amplitude", Vector) = (1.0, 3.0, 2.0, 0.0)
        _WaveSpeed("Wave speed", Float) = 1.0

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

            struct wavePointInfo
            {
                float elevation;
                float4 normal;
            };

            wavePointInfo computeElevation(float3 pos,
                                           float3 waveDirection,
                                           float delta,
                                           float currentTime,
                                           float3 frequency,
                                           float3 amplitude,
                                           float waveSpeed)
            {
               float2 p,wd;     // point in plane and wave direction in xz-plane
               float3 px,pz;     //imagined neibouring vertices for computing the normal
               float d = 0.0; // point's distance along wave direction
               wavePointInfo wpinfo;

               //wave 1
               //wave direction in terms of (x,z)
               wd = float2(cos(radians(waveDirection[0])), sin(radians(waveDirection[0])));
               // point on the surface i.e. xz-plane
               p = pos.xz;

               //compute two neighbours for the new normal later on
               px = float3(p[0] + delta, 0.0f, p[1]);
               d = dot(px.xz, wd);//project px onto wave direction to get its cosine value
               px.y = cos(d * frequency[0] + currentTime * waveSpeed) * amplitude[0];//y from wave 1 for px

               pz = float3(p[0], 0.0f, p[1] + delta);
               d = dot(pz.xz, wd);
               pz.y = cos(d * frequency[0] + currentTime * waveSpeed) * amplitude[0];//y from wave 1 for pz

               d = dot(p, wd);
               wpinfo.elevation = cos(d * frequency[0] + currentTime * waveSpeed) * amplitude[0];//y from wave 1 for p

               //wave 2
               // wave direction in terms of (x,z)
               wd = float2(cos(radians(waveDirection[1])), sin(radians(waveDirection[1])));

               //compute two neighbours for the new normal later on
               d = dot(px.xz, wd);
               px.y = px.y + cos(d * frequency[1] + currentTime * waveSpeed) * amplitude[1];//y from wave 2 for px

               d = dot(pz.xz, wd);
               pz.y = pz.y + cos(d * frequency[1] + currentTime * waveSpeed) * amplitude[1];//y from wave 2 for pz

               d = dot(p, wd);
               wpinfo.elevation = wpinfo.elevation + cos(d * frequency[1] + currentTime * waveSpeed) * amplitude[1];//y from wave 2 for p   

               //wave 3
               // wave direction in terms of (x,z)
               wd = float2(cos(radians(waveDirection[2])), sin(radians(waveDirection[2])));

               //compute two neighbours for the new normal later on
               d = dot(px.xz, wd);
               px.y = px.y + cos(d * frequency[2] + currentTime * waveSpeed) * amplitude[2];//y from wave 3 for px

               d = dot(pz.xz, wd);
               pz.y = pz.y + cos(d * frequency[2] + currentTime * waveSpeed) * amplitude[2];//y from wave 3 for pz

               d = dot(p, wd);
               wpinfo.elevation = wpinfo.elevation + cos(d * frequency[2] + currentTime * waveSpeed) * amplitude[2];//y from wave 3 for p      

               //the new normal
               float3 pxp = px - float3(p[0], wpinfo.elevation, p[1]);
               float3 pzp = pz - float3(p[0], wpinfo.elevation, p[1]);
               wpinfo.normal = float4(cross(pzp, pxp), 1.0);

               return wpinfo;
            }

            float _T;//can use built-in _Time directly
            float4 _WaveDirection;
            float4 _Frequency;
            float4 _Amplitude;
            float _WaveSpeed;

            void vert(float4 vertPos : POSITION,
                      out float4 oNorm : TEXCOORD,
                      out float4 oVertPosView : POSITION1,
                      out float4 oVertPosClip : POSITION0)
            {
                float delta = 0.1f;
                wavePointInfo wpi;

                //calculate vertex y component (elevation) on wave
                wpi = computeElevation(vertPos.xyz, _WaveDirection.xyz, delta, _T, _Frequency.xyz, _Amplitude.xyz, _WaveSpeed);

                //transform normals (obj to view)
                oNorm = mul(UNITY_MATRIX_IT_MV, wpi.normal);

                //transform vertices
                float4 vertPosOnWave = float4(vertPos.x, wpi.elevation, vertPos.z, 1.0);
                oVertPosView = float4(UnityObjectToViewPos(vertPosOnWave.xyz), 1);
                oVertPosClip = UnityObjectToClipPos(vertPosOnWave.xyz);
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
