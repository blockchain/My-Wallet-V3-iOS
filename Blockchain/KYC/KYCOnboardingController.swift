//
//  KYCOnboardingController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Generic & reusable view controller used to present welcome and account screens in KYC flow
class KYCOnboardingController: UIViewController, KYCOnboardingNavigation {

    // MARK: - Properties

    var segueIdentifier: String?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - IBOutlets

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var primaryButton: PrimaryButton!

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        fatalError("primaryButtonTapped(sender:) has not been implemented")
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
