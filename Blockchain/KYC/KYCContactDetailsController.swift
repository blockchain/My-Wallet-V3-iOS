//
//  KYCContactDetailsController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// First and last name entry screen in KYC flow
class KYCContactDetailsController: UIViewController, KYCOnboardingNavigation {

    // MARK: - Properties

    var segueIdentifier: String? = "verifyEmailAddress"

    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailAddressField: UITextField!
    @IBOutlet var primaryButton: PrimaryButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Your Contact Details"
        primaryButton.setTitle("Continue", for: .normal)
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: segueIdentifier!, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }
}
