using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Card : MonoBehaviour {

    private SelectionAndSubmission SelectionAndSubmission;
    public string cardName;//卡牌名称
    public bool isSelect = false;//是否已被选中

    private GameObject indicator;//指示物

    // Use this for initialization
    void Start () {
        cardName = this.gameObject.name;
    }

    public bool BeClick(SelectionAndSubmission sas, GameObject indicatorPrefab)
    {
        if (SelectionAndSubmission == null)
        {
            SelectionAndSubmission = sas;
        }

        if (isSelect)
        {
            Destroy(indicator);
            indicator = null;
            SelectionAndSubmission.SubmitEvent -= WhenSubmit;
        }
        else
        {
            indicator = Instantiate(indicatorPrefab, this.transform);
            SelectionAndSubmission.SubmitEvent += WhenSubmit;
        }
        isSelect = !isSelect;

        return isSelect;
    }

    public void WhenSubmit()
    {
        SelectionAndSubmission.nameOfAllSelectedCards.Add(cardName);
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
