//
//  KYCConfirmPhoneNumberController.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCConfirmPhoneNumberController: UIViewController, KYCOnboardingNavigation {

    var segueIdentifier: String? = "promptForAddress"

    @IBOutlet var primaryButton: PrimaryButton!

    @IBAction func primaryButtonTapped(_ sender: Any) {
        guard let segueIdentifier = segueIdentifier else {
            Logger.shared.info("segueIdentifier is nil. Can't go to next step.")
            return
        }
        self.performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
}
