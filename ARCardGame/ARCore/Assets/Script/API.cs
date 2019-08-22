using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class API : MonoBehaviour
{

    public Text responseText;

    public void Request()
    {
        WWWForm form = new WWWForm();
        form.AddField("Question", responseText.text);

        WWW www = new WWW("https://23261f9vc0.execute-api.ap-southeast-2.amazonaws.com/beta", form);

        StartCoroutine(OnResponse(www));
    }

    IEnumerator OnResponse(WWW www)
    {
        yield return www;

        responseText.text = www.text;
    }
}




