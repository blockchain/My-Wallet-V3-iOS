//
//  KYCVerifyEmailAddressController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/19/18.
//  Copyright © 2018 Blockchain. All rights reserved.
//

import UIKit

final class KYCVerifyEmailAddressController: UIViewController, KYCOnboardingNavigation {

    // MARK: - Properties

    var segueIdentifier: String? = "verifyPhoneNumber"

    @IBOutlet var primaryButton: PrimaryButton!

    @IBAction func primaryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: segueIdentifier!, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }
}
