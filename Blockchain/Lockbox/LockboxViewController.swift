//
//  LockboxViewController.swift
//  Blockchain
//
//  Created by Maurice A. on 10/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class LockboxViewController: UIViewController {

    // MARK: Private Properties

    private var hasSyncedLockbox: Bool {
        return LockboxRepository().lockboxes().count > 0
    }

    // MARK: - IBOutlets

    @IBOutlet private var mainCardView: UIView!
    @IBOutlet private var mainCardTitleLabel: UILabel!
    @IBOutlet private var mainCardDescriptionLabel: UILabel!
    @IBOutlet private var mainCardImageView: UIImageView!
    @IBOutlet private var mainCardButton: UIButton!
    
    @IBOutlet private var announcementCardView: UIView!
    @IBOutlet private var announcementCardTitleLabel: UILabel!
    @IBOutlet private var announcementCardDescriptionLabel: UILabel!
    @IBOutlet private var announcementCardImageView: UIImageView!

    @IBOutlet private var learnMoreLabel: UILabel!
    // MARK: - IBActions

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction private func mainCardButtonTapped(_ sender: Any) {
        if hasSyncedLockbox {
            launchWebViewController(url: Constants.Url.blockchainWalletLogin, title: "Blockchain Wallet")
        } else {
            launchWebViewController(url: Constants.Url.lockbox, title: "Blockchain Lockbox")
        }
    }

    // View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        addShadow(to: mainCardView.layer)

        mainCardButton.layer.cornerRadius = 4

        if !hasSyncedLockbox {
            mainCardTitleLabel.text = LocalizationConstants.Lockbox.getYourLockbox
            mainCardDescriptionLabel.text = LocalizationConstants.Lockbox.safelyStoreYourLockbox
            mainCardImageView.image = #imageLiteral(resourceName: "Image-LockboxDevice")
            mainCardButton.setTitle(LocalizationConstants.Lockbox.buyNowFor99, for: .normal)

            addShadow(to: announcementCardView.layer)
            announcementCardTitleLabel.text = LocalizationConstants.Lockbox.alreadyOwnOne
            announcementCardDescriptionLabel.text = LocalizationConstants.Lockbox.announcementCardSubtitle
            announcementCardDescriptionLabel.sizeToFit()
        } else {
            mainCardTitleLabel.text = LocalizationConstants.Lockbox.balancesComingSoon
            mainCardDescriptionLabel.text = LocalizationConstants.Lockbox.balancesComingSoonSubtitle
            mainCardDescriptionLabel.font = UIFont(
                name: Constants.FontNames.montserratRegular,
                size: Constants.FontSizes.Small
            )

            mainCardImageView.image = #imageLiteral(resourceName: "Image-WebDashboard")
            mainCardButton.setTitle(LocalizationConstants.Lockbox.checkMyBalance, for: .normal)
            announcementCardView.isHidden = true
        }

        let font = UIFont(
            name: Constants.FontNames.montserratRegular,
            size: Constants.FontSizes.ExtraExtraExtraSmall
        ) ?? UIFont.systemFont(ofSize: Constants.FontSizes.ExtraExtraExtraSmall)
        let labelAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.gray5
        ]
        let labelText = NSMutableAttributedString(
            string: String(
                format: LocalizationConstants.Lockbox.wantToLearnMoreX,
                Constants.Url.lockbox
            ),
            attributes: labelAttributes
        )
        labelText.addForegroundColor(UIColor.brandSecondary, to: Constants.Url.lockbox)
        learnMoreLabel.attributedText = labelText
    }

    @IBAction private func onFooterTapped(_ sender: UITapGestureRecognizer) {
        guard let text = learnMoreLabel.text else {
            return
        }
        if let lockboxRange = text.range(of: Constants.Url.lockbox),
            sender.didTapAttributedText(in: learnMoreLabel, range: NSRange(lockboxRange, in: text)) {
            launchWebViewController(url: Constants.Url.lockbox, title: LocalizationConstants.SideMenu.lockbox)
        }
    }

    private func launchWebViewController(url: String, title: String) {
        let viewController = SettingsWebViewController()
        viewController.urlTargetString = url
        let navigationController = BCNavigationController(rootViewController: viewController, title: title)
        present(navigationController, animated: true)
    }

    private func addShadow(to cardLayer: CALayer) {
        cardLayer.cornerRadius = 4
        cardLayer.backgroundColor = UIColor.white.cgColor
        cardLayer.shadowOffset = CGSize(width: 0, height: 2)
        cardLayer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        cardLayer.shadowOpacity = 1
        cardLayer.shadowRadius = 4
    }
}
