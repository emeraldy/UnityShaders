using UnityEngine;

public class Colour_screeny : MonoBehaviour
{
    Camera mainCamera;
    Material mainMaterial;
    float minY, maxY;

    void Start()
    {
        mainCamera = Camera.main;
        mainMaterial = gameObject.GetComponent<Renderer>().material;
        minY = 0;
        maxY = 0;
        //it seems camera.projectmatrix isn't ready at this point
        //so unlike the case of showing colour by view coordinates, we can't initiate range here.
        //to get the first correct rendering, simple click on the screen once (see update logic)
    }
    void Update()
    {
        if (Input.GetMouseButton(0) || Input.GetKeyDown("c") || Input.GetAxis("Mouse ScrollWheel") != 0)
        {
            //range for the initial pose
            Mesh mesh = GetComponent<MeshFilter>().mesh;
            Vector3[] vertices = mesh.vertices;
            Matrix4x4 obj2Clip = mainCamera.projectionMatrix * mainCamera.worldToCameraMatrix * transform.localToWorldMatrix;
            float screenY;
            //built-in matrix4x4.multiplypoint function gives wrong results so manually calcuate the relevant y and w components
            float w = Vector4.Dot(obj2Clip.GetRow(3), new Vector4(vertices[0].x, vertices[0].y, vertices[0].z, 1.0f));
            minY = maxY = (Vector4.Dot(obj2Clip.GetRow(1), new Vector4(vertices[0].x, vertices[0].y, vertices[0].z, 1.0f)) / w + 1) / 2 * Screen.height;
            for (int i = 1; i < vertices.Length; i++)
            {
                w = Vector4.Dot(obj2Clip.GetRow(3), new Vector4(vertices[i].x, vertices[i].y, vertices[i].z, 1.0f));
                screenY = (Vector4.Dot(obj2Clip.GetRow(1), new Vector4(vertices[i].x, vertices[i].y, vertices[i].z, 1.0f)) / w + 1) / 2 * Screen.height;
                if (screenY < minY)
                    minY = screenY;
                if (screenY > maxY)
                    maxY = screenY;
            }
            //pass the range to shader
            mainMaterial.SetFloat("_MinY", minY);
            mainMaterial.SetFloat("_MaxY", maxY);
        }
    }
}
