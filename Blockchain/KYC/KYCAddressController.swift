//
//  KYCAddressController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Address entry screen in KYC flow
class KYCAddressController: UIViewController, KYCOnboardingNavigation {

    // MARK: - Properties

    var segueIdentifier: String? = "showPersonalDetails"

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
