using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
#if UNITY_5_4_OR_NEWER
    [ImageEffectAllowedInSceneView]
#endif
public class RoughnessStencil : MonoBehaviour
{
    static class Uniforms
    {
        internal static readonly int _RoughnessThreashold = Shader.PropertyToID("_RoughnessThreashold");
    }

    private Camera m_Camera;
    private Camera camera_
    {
        get
        {
            if (m_Camera == null)
            {
                m_Camera = GetComponent<Camera>();
            }
            return m_Camera;
        }
    }

    private Shader m_Shader;
    private Shader shader
    {
        get
        {
            if (m_Shader == null)
            {
                m_Shader = Shader.Find("Hidden/StencilRoughness");
            }

            return m_Shader;
        }
    }

    private Material m_Material;
    private Material material
    {
        get
        {
            if (m_Material == null)
            {
                m_Material = new Material(shader);
            }

            return m_Material;
        }
    }

    [Range(0f, 1f)]
    public float roughnessThreashold = .5f;

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetFloat(Uniforms._RoughnessThreashold, roughnessThreashold);

        // Pass zero resets the stencil buffer
        Graphics.Blit(source, destination, material, 0);

        // Pass one writes one t specific pixels based on fragemt shader
        Graphics.Blit(source, destination, material, 1);

        // Pass two applies the image effect for stencil = 0
        Graphics.Blit(source, destination, material, 2);

        // Pass three applies the image effect fr stencil = 1
        Graphics.Blit(source, destination, material, 3);
    }
}
