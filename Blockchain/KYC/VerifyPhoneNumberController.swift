//
//  VerifyPhoneNumberController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

open class VerifyPhoneNumberController: UIViewController & OnboardingNavigation {

    // MARK: Properties

    public var segueIdentifier: String? = "promptForAddress"

    @IBOutlet public var primaryButton: PrimaryButton!

    // MARK: - View Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
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
