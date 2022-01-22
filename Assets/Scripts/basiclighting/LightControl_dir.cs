using UnityEngine;

public class LightControl_dir : MonoBehaviour
{
    public GameObject lightSource;
    public GameObject sceneObject;

    private Material lightMaterial;
    private Material[] objectMaterials;

    //light source attributes
    private Vector4 ambient;
    private Vector4 diffuse;
    private Vector4 specular;
    private Vector3 direction;//in view space

    void Start()
    {
        lightMaterial = lightSource.GetComponent<MeshRenderer>().material;
        objectMaterials = sceneObject.GetComponent<MeshRenderer>().materials;
    }

    void Update()
    {
        ambient = lightMaterial.GetVector("_Ambient");
        diffuse = lightMaterial.GetVector("_Diffuse");
        specular = lightMaterial.GetVector("_Specular");

        //calculate current light direction in view space based on the indicator object in the scene
        //(whose direction in object space is [0, -1, 0])
        direction = lightSource.transform.TransformDirection(0, -1, 0);
        direction = Camera.main.worldToCameraMatrix.MultiplyVector(direction);

        //pass light info to ship material
        for (int i = 0; i < objectMaterials.Length; i++)
        {
            objectMaterials[i].SetVector("_Li_Ambient", ambient);
            objectMaterials[i].SetVector("_Li_Diffuse", diffuse);
            objectMaterials[i].SetVector("_Li_Specular", specular);
            objectMaterials[i].SetVector("_Li_Direction", new Vector4(direction.x, direction.y,
                                         direction.z, 0.0f));//w for a direction must be 0
        }
    }
}
