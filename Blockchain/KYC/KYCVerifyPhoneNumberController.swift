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

    @IBOutlet var textFieldMobileNumber: UITextField!
    @IBOutlet var primaryButton: PrimaryButton!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textFieldMobileNumber.becomeFirstResponder()
    }

    // MARK: - Actions

    @IBAction func textFieldDidChange(_ sender: UITextField) {
    }

    @IBAction func primaryButtonTapped(_ sender: Any) {
//        self.performSegue(withIdentifier: segueIdentifier!, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }
}
