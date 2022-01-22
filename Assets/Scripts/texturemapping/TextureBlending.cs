using UnityEngine;

public class TextureBlending : MonoBehaviour
{
    private Material earthMat;
    private float speed;

    void Start()
    {
        earthMat = gameObject.GetComponent<Renderer>().material;
        speed = 0.5f;
    }

    void Update()
    {
        earthMat.SetFloat("_T", (Mathf.Sin(Time.time * speed) + 1.0f) / 2.0f);
    }
}
