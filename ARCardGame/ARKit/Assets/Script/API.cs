using System.Collections;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEngine.UI;

public class API : MonoBehaviour
{
    public Text readText;

    string getURL = "https://23261f9vc0.execute-api.ap-southeast-2.amazonaws.com/beta?gameid=1";

    public void Request()
    {
        StartCoroutine(OnResponse());
    }

    IEnumerator OnResponse()
    {
        string URL = getURL;
        WWW www = new WWW(URL);
        yield return www;
        string fulltext = www.text;
        int a = fulltext.IndexOf("Question");
        int b = fulltext.IndexOf("Solution");
        string bb = fulltext.Substring(a+11,b-a-14);
        readText.text = bb;
    }
}

