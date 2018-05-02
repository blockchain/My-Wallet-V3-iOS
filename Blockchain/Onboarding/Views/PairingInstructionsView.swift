//
//  BCPairingInstructionsView.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol PairingInstructionsViewDelegate: class {
    func onScanQRCodeClicked()

    func onManualPairClicked()
}

/**
 View displaying instructions to the user on how to pair.
*/
class PairingInstructionsView: BCModalContentView {
    @IBOutlet weak var textViewStepOne: UITextView!
    @IBOutlet weak var textViewStepTwo: UITextView!
    @IBOutlet weak var textViewStepThree: UITextView!
    @IBOutlet weak var buttonScanPairing: UIButton!
    @IBOutlet weak var buttonManualPair: UIButton!

    weak var delegate: PairingInstructionsViewDelegate?

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
        delegate?.onScanQRCodeClicked()
    }

    @IBAction func manualPairClicked(_ sender: Any) {
        delegate?.onManualPairClicked()
    }
}

extension PairingInstructionsView {
    static func instanceFromNib() -> PairingInstructionsView {
        let nib = UINib(nibName: "MainWindow", bundle: Bundle.main)
        let contents = nib.instantiate(withOwner: nil, options: nil)
        return contents.first { item -> Bool in
            item is PairingInstructionsView
        } as! PairingInstructionsView
    }
}
