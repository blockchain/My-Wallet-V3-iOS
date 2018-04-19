//
//  BCPairingInstructionsView.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 View displaying instructions to the user on how to pair.
*/
class PairingInstructionsView: BCModalContentView {
    @IBOutlet weak var textViewStepOne: UITextView!
    @IBOutlet weak var textViewStepTwo: UITextView!
    @IBOutlet weak var textViewStepThree: UITextView!
    @IBOutlet weak var buttonScanPairing: UIButton!
    @IBOutlet weak var buttonManualPair: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        textViewStepOne.font = UIFont(name: Constants.FontNames.gillSans, size: Constants.FontSizes.Medium)
        textViewStepTwo.font = UIFont(name: Constants.FontNames.gillSans, size: Constants.FontSizes.Medium)
        textViewStepThree.font = UIFont(name: Constants.FontNames.gillSans, size: Constants.FontSizes.Medium)

        buttonScanPairing.titleEdgeInsets = UIEdgeInsetsMake(0, 12.5, 0, 12.5)
        buttonScanPairing.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonScanPairing.titleLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Large)

        buttonManualPair.titleEdgeInsets = UIEdgeInsetsMake(0, 12.5, 0, 12.5)
        buttonManualPair.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonManualPair.titleLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Large)
    }

    @IBAction func scanAccountQRCodeClicked(_ sender: Any) {
        // TODO: Handle
    }

    @IBAction func manualPairClicked(_ sender: Any) {
        // TODO: Handle
    }
}

extension PairingInstructionsView {
    static func instanceFromNib() -> PairingInstructionsView {
        let nib = UINib(nibName: "PairingInstructionsView", bundle: Bundle.main)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! PairingInstructionsView
    }
}
