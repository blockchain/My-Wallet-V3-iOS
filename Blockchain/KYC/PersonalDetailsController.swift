//
//  PersonalDetailsController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Personal details entry screen in KYC flow
open class PersonalDetailsController: UIViewController {

    // MARK: - Properties

    // MARK: - View Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        let verifyAccountController = UIStoryboard.instantiate(
            child: VerifyAccountController.self,
            from: OnboardingController.self,
            in: UIStoryboard(name: "OnboardingScreen", bundle: Bundle(identifier: "com.rainydayapps.BlockchainKYC")),
            identifier: "OnboardingScreen"
        )
        self.navigationController?.pushViewController(verifyAccountController, animated: true)
    }
}
