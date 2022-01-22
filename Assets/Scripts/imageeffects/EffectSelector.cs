using UnityEngine;
using UnityEngine.UI;

public class EffectSelector : MonoBehaviour
{
    public ToggleGroup effectChoices;
    public GameObject sceneObject;
    public Material untextured;
    public Material textured;

    private Material fsqMaterial;
    private Renderer sceneObjMeshRenderer;
    private Toggle[] effectToggles;

    void Start()
    {
        fsqMaterial = gameObject.GetComponent<Renderer>().material;
        fsqMaterial.SetVector("_Resolution", new Vector4(Screen.width, Screen.height, 0, 0));

        //starting shader is edge detector
        effectToggles = effectChoices.GetComponentsInChildren<Toggle>();
        foreach (Toggle t in effectToggles)
        {
            t.onValueChanged.AddListener(delegate { EffectSelectorChanged(t); });
        }

        sceneObjMeshRenderer = sceneObject.GetComponent<Renderer>();
    }

    private void EffectSelectorChanged(Toggle toggle)
    {
        if (toggle.isOn)
        {
            string shaderName = "Custom/" + toggle.gameObject.name.ToLower();
            if (toggle.gameObject.name.Equals("Edges"))
            {
                sceneObjMeshRenderer.material = untextured;
            }
            else if (toggle.gameObject.name.Equals("Sharpen"))
            {
                sceneObjMeshRenderer.material = textured;
            }
            else if (toggle.gameObject.name.Equals("Blur"))
            {
                sceneObjMeshRenderer.material = textured;
            }
            else if (toggle.gameObject.name.Equals("Motionblur"))
            {
                sceneObjMeshRenderer.material = textured;
            }
            fsqMaterial.SetVector("_Resolution", new Vector4(Screen.width, Screen.height, 0, 0));
            fsqMaterial.shader = Shader.Find(shaderName);
        }
    }
}
