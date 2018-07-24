//
//  KYCPersonalDetailsController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Personal details entry screen in KYC flow
final class KYCPersonalDetailsController: UIViewController, KYCOnboardingNavigation {

    // MARK: - Properties

    var segueIdentifier: String?

    // MARK: - IBOutlets

    @IBOutlet var primaryButton: PrimaryButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        let verifyAccountController = UIStoryboard.instantiate(
            child: KYCVerifyAccountController.self,
            from: KYCOnboardingController.self,
            in: UIStoryboard(name: "KYCOnboardingScreen", bundle: nil),
            identifier: "OnboardingScreen"
        )
        self.navigationController?.pushViewController(verifyAccountController, animated: true)
    }
}
