//
//  AddressController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Address entry screen in KYC flow
open class AddressController: UIViewController & OnboardingNavigation {

    // MARK: - Properties

    public var segueIdentifier: String? = "showPersonalDetails"

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
