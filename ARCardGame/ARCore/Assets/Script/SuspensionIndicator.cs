using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SuspensionIndicator : MonoBehaviour {

    public float rotateSpeed;
    public float suspensionSpeed;
    public float suspensionRange;

    private float originY;
    private float beginTime;

    // Use this for initialization
    void Start () {
        originY = this.transform.localPosition.y;
        beginTime = Time.time;
    }
	
	// Update is called once per frame
	void Update () {
        Rotate();
        Suspension();
    }

    private void Rotate()
    {
        this.transform.Rotate(new Vector3(0, 1, 0), rotateSpeed, Space.World);
    }

    private void Suspension()
    {
        float y = originY + (Mathf.Sin((Time.time - beginTime) * Mathf.PI * suspensionSpeed)) * suspensionRange;
        Vector3 pos = this.transform.localPosition;
        pos.y = y;
        this.transform.localPosition = pos;
    }
}
