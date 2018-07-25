//
//  WelcomeController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Welcome screen in KYC flow
open class WelcomeController: OnboardingController {

    // MARK: - View Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Exchange"
        segueIdentifier = "showCountrySelector"
        imageView.image = UIImage(named: "Welcome")
        titleLabel.text = "You're almost there"
        descriptionLabel.text = """
        Complete your profile and identity verification to start buying and selling. Don't worry, we only need a couple more details.
        """
        primaryButton.setTitle("Verify My Identity", for: .normal)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    // MARK: - Actions

    override public func primaryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: segueIdentifier!, sender: self)
    }

    // MARK: - Navigation

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
