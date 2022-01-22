using UnityEngine;

public class Pulsate : MonoBehaviour
{
    private Material shipMat;

    public float bloatExtent = 100.0f;
    
	void Start ()
    {
        shipMat = gameObject.GetComponent<Renderer>().material;
        shipMat.SetFloat("_Ext", bloatExtent);
	}
	
	void Update ()
    {
        shipMat.SetFloat("_T", (Mathf.Sin(Time.time) + 1.0f) / 2.0f);
	}
}
