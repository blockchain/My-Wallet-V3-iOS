//
//  KYCAccountStatusController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

struct KYCAccountStatusViewConfig {
    let titleColor: UIColor
    let isPrimaryButtonEnabled: Bool
}

extension KYCAccountStatusViewConfig {
    static let defaultConfig: KYCAccountStatusViewConfig = KYCAccountStatusViewConfig(
        titleColor: UIColor.gray5,
        isPrimaryButtonEnabled: false
    )

    static func create(for accountStatus: KYCAccountStatus) -> KYCAccountStatusViewConfig {
        let titleColor: UIColor
        let isPrimaryButtonEnabled: Bool
        switch accountStatus {
        case .approved:
            titleColor = UIColor.green
            isPrimaryButtonEnabled = true
        case .failed:
            titleColor = UIColor.error
            isPrimaryButtonEnabled = true
        case .inProgress:
            titleColor = UIColor.orange
            isPrimaryButtonEnabled = !UIApplication.shared.isRegisteredForRemoteNotifications
        case .underReview:
            titleColor = UIColor.orange
            isPrimaryButtonEnabled = false
        }
        return KYCAccountStatusViewConfig(
            titleColor: titleColor,
            isPrimaryButtonEnabled: isPrimaryButtonEnabled
        )
    }
}

final class KYCAccountStatusController: UIViewController {

    /// typealias for an action to be taken when the primary button/CTA is tapped
    typealias PrimaryButtonAction = ((KYCAccountStatusController) -> Void)

    // MARK: - Properties

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelSubtitle: UILabel!
    @IBOutlet private var labelDescription: UILabel!
    @IBOutlet private var buttonPrimary: PrimaryButton!

    /// Action invoked when the primary button is tapped
    var primaryButtonAction: PrimaryButtonAction?

    /// Describes the status of the user's account
    var accountStatus: KYCAccountStatus = .failed {
        didSet {
            viewConfig = KYCAccountStatusViewConfig.create(for: accountStatus)
        }
    }

    /// The view configuration for this view
    var viewConfig: KYCAccountStatusViewConfig = KYCAccountStatusViewConfig.defaultConfig

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = accountStatus.image
        labelTitle.text = accountStatus.title
        if let subtitle = accountStatus.subtitle {
            labelSubtitle.text = subtitle
        } else {
            labelSubtitle.superview?.removeFromSuperview()
        }
        labelDescription.text = accountStatus.description
        buttonPrimary.setTitle(accountStatus.primaryButtonTitle, for: .normal)

        labelTitle.textColor = viewConfig.titleColor
        buttonPrimary.isHidden = !viewConfig.isPrimaryButtonEnabled
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        primaryButtonAction?(self)
    }
}
