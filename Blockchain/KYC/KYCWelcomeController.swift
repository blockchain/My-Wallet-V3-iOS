//
//  KYCWelcomeController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Welcome screen in KYC flow
final class KYCWelcomeController: KYCBaseViewController {
    
    // MARK: - IBOutlets

    @IBOutlet private var labelTermsOfService: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCWelcomeController {
        let storyboard = UIStoryboard(name: "KYCWelcome", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! KYCWelcomeController
        controller.coordinator = coordinator
        controller.pageType = .welcome
        return controller
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let font = UIFont(
            name: Constants.FontNames.montserratRegular,
            size: Constants.FontSizes.ExtraExtraExtraSmall
        ) ?? UIFont.systemFont(ofSize: Constants.FontSizes.ExtraExtraExtraSmall)
        let labelAttributes = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: UIColor.gray5
        ]
        let labelText = NSMutableAttributedString(
            string: String(
                format: LocalizationConstants.KYC.termsOfServiceAndPrivacyPolicyNotice,
                LocalizationConstants.tos,
                LocalizationConstants.privacyPolicy
            ),
            attributes: labelAttributes
        )
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.tos)
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.privacyPolicy)
        labelTermsOfService.attributedText = labelText
    }

    // MARK: - Actions

    @IBAction private func onLabelTapped(_ sender: UITapGestureRecognizer) {
        guard let text = labelTermsOfService.text else {
            return
        }
        if let tosRange = text.range(of: LocalizationConstants.tos),
            sender.didTapAttributedText(in: labelTermsOfService, range: NSRange(tosRange, in: text)) {
            launchWebViewController(url: Constants.Url.termsOfService, title: LocalizationConstants.tos)
        }
        if let privacyPolicyRange = text.range(of: LocalizationConstants.privacyPolicy),
            sender.didTapAttributedText(in: labelTermsOfService, range: NSRange(privacyPolicyRange, in: text)) {
            launchWebViewController(url: Constants.Url.privacyPolicy, title: LocalizationConstants.privacyPolicy)
        }
    }

    @IBAction private func primaryButtonTapped(_ sender: Any) {
        coordinator.handle(event: .nextPageFromPageType(pageType))
    }

    // MARK: - Private Methods

    private func launchWebViewController(url: String, title: String) {
        let viewController = SettingsWebViewController()
        viewController.urlTargetString = url
        let navigationController = BCNavigationController(rootViewController: viewController, title: title)
        present(navigationController, animated: true)
    }
}

extension UITapGestureRecognizer {

    /// Checks if the tap occurred inside a specified range within a UILabel.
    /// See: https://stackoverflow.com/a/35789589
    ///
    /// - Parameters:
    ///   - label: the UILabel
    ///   - range: the NSRange
    /// - Returns: true if the tap occurred within `range`, otherwise, false
    func didTapAttributedText(in label: UILabel, range: NSRange) -> Bool {
        guard let attributedText = label.attributedText else {
            return false
        }

        let textStorage = NSTextStorage(attributedString: attributedText)

        let layoutManager = NSLayoutManager()

        let textContainer = NSTextContainer(size: CGSize.zero)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        layoutManager.addTextContainer(textContainer)

        textStorage.addLayoutManager(layoutManager)

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        return NSLocationInRange(indexOfCharacter, range)
    }

}
