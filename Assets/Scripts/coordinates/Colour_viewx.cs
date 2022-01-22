using UnityEngine;

public class Colour_viewx : MonoBehaviour
{
    Camera mainCamera;
    Material mainMaterial;
    float minX, maxX;

    void Start()
    {
        mainCamera = Camera.main;
        mainMaterial = gameObject.GetComponent<Renderer>().material;

        minX = 0;
        maxX = 0;
        //range for the initial pose
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        Vector3[] vertices = mesh.vertices;
        Matrix4x4 obj2View = mainCamera.worldToCameraMatrix * transform.localToWorldMatrix;
        Vector3 viewPos;
        minX = maxX = obj2View.MultiplyPoint3x4(vertices[0]).x;
        for (int i = 1; i < vertices.Length; i++)
        {
            viewPos = obj2View.MultiplyPoint3x4(vertices[i]);
            if (viewPos.x < minX)
                minX = viewPos.x;
            if (viewPos.x > maxX)
                maxX = viewPos.x;
        }
        //pass the range to shader
        mainMaterial.SetFloat("_MinX", minX);
        mainMaterial.SetFloat("_MaxX", maxX);
    }

    void Update()
    {
        if (Input.GetMouseButton(0) || Input.GetKeyDown("c") || Input.GetAxis("Mouse ScrollWheel") != 0)
        {//only compute the new min/max when there is camera movement
            Mesh mesh = GetComponent<MeshFilter>().mesh;
            Vector3[] vertices = mesh.vertices;
            Matrix4x4 obj2View = mainCamera.worldToCameraMatrix * transform.localToWorldMatrix;
            Vector3 viewPos;
            minX = maxX = obj2View.MultiplyPoint3x4(vertices[0]).x;
            for (int i = 1; i < vertices.Length; i++)
            {
                viewPos = obj2View.MultiplyPoint3x4(vertices[i]);
                if (viewPos.x < minX)
                    minX = viewPos.x;
                if (viewPos.x > maxX)
                    maxX = viewPos.x;
            }
            //pass the range to shader
            mainMaterial.SetFloat("_MinX", minX);
            mainMaterial.SetFloat("_MaxX", maxX);
        }
    }
}
