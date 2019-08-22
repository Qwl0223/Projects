using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SelectionAndSubmission : MonoBehaviour {

    public delegate void SubmitDelegate();
    public static SubmitDelegate SubmitEvent;


    [Header("Basic Setting")]
    public float maxRayDistance;//the max distance of ray
    public LayerMask cardLayer;//card layer
    public GameObject indicatorPrefab;
    public Button submitButton;

    [Header("State Overview")]
    public int numberOfCardsSelected;//number of selected cards

    [Header("Submit Data Overview")]
    public List<string> nameOfAllSelectedCards;

    // Use this for initialization
    void Start () {
		
	}

    public static void OnSubmitEvent()
    {
        if (SubmitEvent != null)
        {
            SubmitEvent();
        }
    }

    public void Submit()
    {
        nameOfAllSelectedCards.Clear();
        OnSubmitEvent();
    }

    private void EnableSubmitButton()//Contorl confirm button
    {
        if (numberOfCardsSelected == 0 && submitButton.IsInteractable())
        {
            submitButton.interactable = false;
        }
        else if (numberOfCardsSelected != 0 && !submitButton.IsInteractable())
        {
            submitButton.interactable = true;
        }
    }

    // Update is called once per frame
    void Update () {
        SelectCard();
    }

    private void SelectCard()
    {
#if UNITY_EDITOR //test
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit, maxRayDistance, cardLayer))
            {
                if(hit.collider.gameObject.GetComponent<Card>().BeClick(this, indicatorPrefab))
                {
                    numberOfCardsSelected++;
                }
                else
                {
                    numberOfCardsSelected--;
                }
                EnableSubmitButton();
            }
        }
#endif
        //choose cards
        if (Input.touchCount == 1)
        {
            if(Input.touches[0].phase == TouchPhase.Began)
            {
                Ray ray = Camera.main.ScreenPointToRay(Input.touches[0].position);
                RaycastHit hit;

                if (Physics.Raycast(ray, out hit, maxRayDistance, cardLayer))
                {
                    if (hit.collider.gameObject.GetComponent<Card>().BeClick(this, indicatorPrefab))
                    {
                        numberOfCardsSelected++;
                    }
                    else
                    {
                        numberOfCardsSelected--;
                    }
                    EnableSubmitButton();
                }
            }
        }
    }
}
