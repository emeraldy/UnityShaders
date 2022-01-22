/*this script is crucial to do MRT based on scene objects. Leave Target Texture of the concerned camera empty and use this script to set multiple colour buffers*/
using UnityEngine;

public class GenerateGbuffer : MonoBehaviour
{
    public RenderTexture GBDiffuse;
    public RenderTexture GBSpecular;
    public RenderTexture GBColour;

    private RenderBuffer[] gbuffers;

    private void Start()
    {
        gbuffers = new RenderBuffer[3];
        gbuffers[0] = GBDiffuse.colorBuffer;
        gbuffers[1] = GBSpecular.colorBuffer;
        gbuffers[2] = GBColour.colorBuffer;

        Camera thisCamera = gameObject.GetComponent<Camera>();
        thisCamera.SetTargetBuffers(gbuffers, GBDiffuse.depthBuffer);
    }
}
