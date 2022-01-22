using UnityEngine;

public class SkyboxControl : MonoBehaviour
{
    public Camera mainCamera;

    private Material material;
    private Matrix4x4 projMatrix;

    void Start()
    {
        material = gameObject.GetComponent<Renderer>().material;
    }

    void Update()
    {
        projMatrix = GL.GetGPUProjectionMatrix(mainCamera.projectionMatrix, false);
        projMatrix = projMatrix.inverse;
        material.SetVector("_InVProjRow0", projMatrix.GetRow(0));
        material.SetVector("_InVProjRow1", projMatrix.GetRow(1));
        material.SetVector("_InVProjRow2", projMatrix.GetRow(2));
        material.SetVector("_InVProjRow3", projMatrix.GetRow(3));
    }
}
