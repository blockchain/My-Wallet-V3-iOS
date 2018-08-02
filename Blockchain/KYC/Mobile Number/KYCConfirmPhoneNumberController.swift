//
//  KYCConfirmPhoneNumberController.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCConfirmPhoneNumberController: UIViewController {

    @IBOutlet var nextButton: PrimaryButton!

    // MARK: IBActions
    @IBAction func onResendCodeTapped(_ sender: Any) {
    }

    @IBAction func onNextTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "promptForAddress", sender: nil)
    }
    
    @IBAction func onTextFieldChanged(_ sender: Any) {
    }
}

extension KYCConfirmPhoneNumberController: UITextFieldDelegate {

}
