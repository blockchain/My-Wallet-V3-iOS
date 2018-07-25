//
//  ContactDetailsController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// First and last name entry screen in KYC flow
open class ContactDetailsController: UIViewController & OnboardingNavigation {

    // MARK: - Properties

    open var segueIdentifier: String? = "verifyEmailAddress"

    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailAddressField: UITextField!
    @IBOutlet public var primaryButton: PrimaryButton!

    // MARK: - View Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Your Contact Details"
        primaryButton.setTitle("Continue", for: .normal)
        // firstNameField.becomeFirstResponder()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions

    @IBAction public func primaryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: segueIdentifier!, sender: self)
    }

    // MARK: - Navigation

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
