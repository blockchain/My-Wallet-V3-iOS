//
//  KYCCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Coordinates the KYC flow. This component can be used to start a new KYC flow, or if
/// the user drops off mid-KYC and decides to continue through it again, the coordinator
/// will handle recovering where they left off.
@objc class KYCCoordinator: NSObject, Coordinator {

    func start() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
            return
        }
        start(from: rootViewController)
    }

    @objc func start(from viewController: UIViewController) {
        guard let welcomeViewController = UIStoryboard(
            name: "KYCWelcome",
            bundle: Bundle.main
        ).instantiateInitialViewController() as? KYCWelcomeController else {
            Logger.shared.warning("Could not instantiated KYCWelcomeController")
            return
        }
        presentInNavigationController(welcomeViewController, in: viewController)
    }

    func presentAccountStatusView(for status: KYCAccountStatus, in viewController: UIViewController) {
        guard let accountStatusViewController = UIStoryboard(
            name: "KYCAccountStatus",
            bundle: Bundle.main
        ).instantiateInitialViewController() as? KYCAccountStatusController else {
            Logger.shared.warning("Could not instantiated KYCAccountStatusController")
            return
        }
        accountStatusViewController.accountStatus = status
        accountStatusViewController.primaryButtonAction = { viewController in
            switch viewController.accountStatus {
            case .approved:
                viewController.dismiss(animated: true) {
                    ExchangeCoordinator.shared.start()
                }
            case .inProgress:
                PushNotificationManager.shared.requestAuthorization()
            case .failed:
                // Confirm with design that this is how we should handle this
                guard let url = URL(string: Constants.Url.blockchainSupport) else { return }
                UIApplication.shared.open(url)
            default:
                return
            }
        }
        presentInNavigationController(accountStatusViewController, in: viewController)
    }

    // MARK: Private Methods

    private func presentInNavigationController(_ viewController: UIViewController, in presentingViewController: UIViewController) {
        guard let navigationController = UIStoryboard(
            name: "KYCOnboardingNavigation",
            bundle: Bundle.main
        ).instantiateInitialViewController() as? KYCOnboardingNavigationController else {
            Logger.shared.warning("Could not instantiated KYCOnboardingNavigationController")
            return
        }
        navigationController.pushViewController(viewController, animated: false)
        navigationController.modalTransitionStyle = .coverVertical
        presentingViewController.present(navigationController, animated: true)
    }
}
