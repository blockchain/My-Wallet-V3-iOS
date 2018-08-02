//
//  KYCConfirmPhoneNumberController.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCConfirmPhoneNumberController: UIViewController {

    @IBOutlet var primaryButton: PrimaryButton!

    @IBAction func primaryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "promptForAddress", sender: nil)
    }
}
