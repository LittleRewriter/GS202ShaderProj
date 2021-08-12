using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateBox : MonoBehaviour
{
    void Update()
    {
        transform.eulerAngles = new Vector3(.0f, Time.time * 10, .0f);       
    }
}
