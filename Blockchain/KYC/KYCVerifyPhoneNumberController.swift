//
//  KYCVerifyPhoneNumberController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

final class KYCVerifyPhoneNumberController: UIViewController, KYCOnboardingNavigation {

    // MARK: Properties

    var segueIdentifier: String? = "promptForAddress"

    @IBOutlet var primaryButton: PrimaryButton!

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: segueIdentifier!, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }
}
