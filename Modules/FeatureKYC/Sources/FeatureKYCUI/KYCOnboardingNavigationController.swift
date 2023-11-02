// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

protocol KYCOnboardingNavigationControllerDelegate: AnyObject {
    func navControllerCTAType() -> NavigationCTA
    func navControllerRightBarButtonTapped(_ navController: KYCOnboardingNavigationController)
}

/// NOTE: - This class prefetches some of the data to mitigate loading states in subsequent view controllers
final class KYCOnboardingNavigationController: UINavigationController {

    weak var onboardingDelegate: KYCOnboardingNavigationControllerDelegate?

    // MARK: - Initialization

    class func make() -> KYCOnboardingNavigationController {
        let controller = makeFromStoryboard(in: .module)
        return controller
    }

    func setupBarButtonItem() {
        guard let CTA = onboardingDelegate?.navControllerCTAType() else { return }
        var button: UIBarButtonItem {
            if let image = CTA.image {
                .init(
                    image: image,
                    style: .plain,
                    target: self,
                    action: #selector(rightBarButtonTapped)
                )
            } else {
                .init(
                    title: CTA.title,
                    style: .plain,
                    target: self,
                    action: #selector(rightBarButtonTapped)
                )
            }
        }
        guard let navItem = visibleViewController?.navigationItem else { return }
        navItem.rightBarButtonItem = CTA.visibility.isHidden ? nil : button
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc fileprivate func rightBarButtonTapped() {
        onboardingDelegate?.navControllerRightBarButtonTapped(self)
    }
}
