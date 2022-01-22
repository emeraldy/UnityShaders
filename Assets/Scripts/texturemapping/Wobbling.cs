using UnityEngine;

public class Wobbling : MonoBehaviour
{
    private Material mainMaterial;
    private Vector4 phase;

    void Start()
    {
        mainMaterial = gameObject.GetComponent<Renderer>().material;
        phase = new Vector4();
    }
    void Update()
    {
        phase.x = Input.mousePosition.x / Screen.width * 10;
        phase.y = Input.mousePosition.y / Screen.height * 10;

        mainMaterial.SetVector("_Phase", phase);
    }
}
