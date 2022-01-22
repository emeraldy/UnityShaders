using UnityEngine;

public class Wavy : MonoBehaviour
{
    private Material surfaceMat;

    void Start()
    {
        surfaceMat = gameObject.GetComponent<Renderer>().material;
    }

    void Update()
    {
        surfaceMat.SetFloat("_T", Time.time);
    }
}
