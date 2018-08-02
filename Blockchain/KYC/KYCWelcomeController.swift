//
//  KYCWelcomeController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Welcome screen in KYC flow
final class KYCWelcomeController: UIViewController {

    // MARK: - Properties

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Actions

    @IBAction private func primaryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showCountrySelector", sender: self)
    }
}
