import FeatureFormDomain
import XCTest

final class FormTests: XCTestCase {

    func test() throws {

        try JSONDecoder().decode(FeatureFormDomain.Form.self, from: json)

    }
}

let json = Data("""
{
  "context": "TIER_TWO_VERIFICATION",
  "pages": [
    {
      "nodes": [
        {
          "id": "q1",
          "type": "MULTIPLE_SELECTION",
          "text": "Nature and purpose of business relationship (select all that apply)",
          "children": [
            {
              "id": "q1-a1",
              "type": "SELECTION",
              "text": "Buy cryptocurrencies with cards or bank transfer"
            },
            {
              "id": "q1-a2",
              "type": "SELECTION",
              "text": "Swap my cryptocurrencies"
            },
            {
              "id": "q1-a3",
              "type": "SELECTION",
              "text": "Depositing cryptocurrency to earn interest"
            },
            {
              "id": "q1-a4",
              "type": "SELECTION",
              "text": "Depositing cryptocurrency as collateral to borrow stablecoins"
            }
          ]
        },
        {
          "id": "q2",
          "type": "SINGLE_SELECTION",
          "text": "Source of funds (select one only)",
          "children": [
            {
              "id": "q2-a1",
              "type": "SELECTION",
              "text": "Salary"
            },
            {
              "id": "q2-a2",
              "type": "SELECTION",
              "text": "Crypto Trading"
            },
            {
              "id": "q2-a3",
              "type": "SELECTION",
              "text": "Crypto Mining"
            },
            {
              "id": "q2-a4",
              "type": "SELECTION",
              "text": "Investment Income"
            },
            {
              "id": "q2-a5",
              "type": "SELECTION",
              "text": "Real Estate"
            },
            {
              "id": "q2-a6",
              "type": "SELECTION",
              "text": "Inheritance"
            },
            {
              "id": "q2-a7",
              "type": "SELECTION",
              "text": "Family"
            },
            {
              "id": "q2-a8",
              "type": "SELECTION",
              "text": "Other"
            }
          ]
        },
        {
          "id": "q3",
          "type": "SINGLE_SELECTION",
          "text": "Are you acting on your own behalf?",
          "children": [
            {
              "id": "q3-a1",
              "type": "SELECTION",
              "text": "Yes"
            },
            {
              "id": "q3-a2",
              "type": "SELECTION",
              "text": "No"
            }
          ]
        }
      ]
    },
    {
      "nodes": [
        {
          "id": "q4",
          "type": "MULTIPLE_SELECTION",
          "text": "Nature and purpose of business relationship (select all that apply)",
          "children": [
            {
              "id": "q4-a1",
              "type": "SELECTION",
              "text": "Buy cryptocurrencies with cards or bank transfer"
            },
            {
              "id": "q4-a2",
              "type": "SELECTION",
              "text": "Swap my cryptocurrencies"
            },
            {
              "id": "q4-a3",
              "type": "SELECTION",
              "text": "Depositing cryptocurrency to earn interest"
            },
            {
              "id": "q4-a4",
              "type": "SELECTION",
              "text": "Depositing cryptocurrency as collateral to borrow stablecoins"
            }
          ]
        },
        {
          "id": "q5",
          "type": "SINGLE_SELECTION",
          "text": "Source of funds (select one only)",
          "children": [
            {
              "id": "q5-a1",
              "type": "SELECTION",
              "text": "Salary"
            },
            {
              "id": "q5-a2",
              "type": "SELECTION",
              "text": "Crypto Trading"
            },
            {
              "id": "q5-a3",
              "type": "SELECTION",
              "text": "Crypto Mining"
            },
            {
              "id": "q5-a4",
              "type": "SELECTION",
              "text": "Investment Income"
            },
            {
              "id": "q5-a5",
              "type": "SELECTION",
              "text": "Real Estate"
            },
            {
              "id": "q5-a6",
              "type": "SELECTION",
              "text": "Inheritance"
            },
            {
              "id": "q5-a7",
              "type": "SELECTION",
              "text": "Family"
            },
            {
              "id": "q5-a8",
              "type": "SELECTION",
              "text": "Other"
            }
          ]
        },
        {
          "id": "q6",
          "type": "SINGLE_SELECTION",
          "text": "Are you acting on your own behalf?",
          "children": [
            {
              "id": "q6-a1",
              "type": "SELECTION",
              "text": "Yes"
            },
            {
              "id": "q6-a2",
              "type": "SELECTION",
              "text": "No"
            }
          ]
        },
        {
          "id": "q7",
          "type": "SINGLE_SELECTION",
          "text": "Are you a Politically Exposed Person (PEP)",
          "children": [
            {
              "id": "q7-a1",
              "type": "SELECTION",
              "text": "Yes, I am"
            },
            {
              "id": "q7-a2",
              "type": "SELECTION",
              "text": "Yes, my family member or close associate is (please indicate)",
              "children": [
                {
                  "id": "q7-a2-a1",
                  "type": "OPEN_ENDED",
                  "text": "Name, Last Name"
                },
                {
                  "id": "q7-a2-a2",
                  "type": "OPEN_ENDED",
                  "text": "Relation with this person (family member, associate)"
                }
              ]
            },
            {
              "id": "q7-a3",
              "type": "SELECTION",
              "text": "No"
            }
          ]
        }
      ]
    }
  ]
}
""".utf8)
