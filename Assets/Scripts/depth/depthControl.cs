using UnityEngine;

public class depthControl : MonoBehaviour
{
    private Material fsqMaterial;

    void Start()
    {
        fsqMaterial = gameObject.GetComponent<Renderer>().material;
        fsqMaterial.SetFloat("_Enabled", 1);
        fsqMaterial.SetVector("_Resolution", new Vector4(Screen.width, Screen.height, 0, 0));
    }

    void Update()
    {
        if (Input.GetKeyDown("b"))
        {
            fsqMaterial.SetFloat("_Enabled", 1 - fsqMaterial.GetFloat("_Enabled"));
        }
    }
}
