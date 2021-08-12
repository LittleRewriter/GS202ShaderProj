using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RollingTexture : MonoBehaviour
{
    private Renderer mRenderer;
    [SerializeField] float rotateSpeed;
    void Start()
    {
        mRenderer = GetComponent<Renderer>();
    }

    // Update is called once per frame
    void Update()
    {
        float t = Time.time;
        mRenderer.material.SetTextureOffset("_MainTex", new Vector2(t, 0) * rotateSpeed);
    }
}
