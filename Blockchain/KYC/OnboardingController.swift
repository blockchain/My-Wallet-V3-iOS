//
//  OnboardingController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Generic & reusable view controller used to present welcome and account screens in KYC flow
open class OnboardingController: UIViewController & OnboardingNavigation {

    // MARK: - Properties

    open var segueIdentifier: String?

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - IBOutlets

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet public var primaryButton: PrimaryButton!

    // MARK: - View Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    // MARK: - Actions

    @IBAction public func primaryButtonTapped(_ sender: Any) {
        fatalError("primaryButtonTapped(sender:) has not been implemented")
    }

    // MARK: - Navigation

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
