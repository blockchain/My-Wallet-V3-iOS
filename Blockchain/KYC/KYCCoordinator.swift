//
//  KYCCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class KYCCoordinator: NSObject, Coordinator {

    func start() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
            return
        }
        start(from: rootViewController)
    }

    @objc func start(from viewController: UIViewController) {
        let navigationController = UIStoryboard(name: "KYCOnboardingNavigation", bundle: nil)
            .instantiateViewController(withIdentifier: "OnboardingNavigation") as! KYCOnboardingNavigationController

        let welcomeViewController = UIStoryboard(name: "KYCWelcome", bundle: nil)
            .instantiateViewController(withIdentifier: "KYCWelcomeController") as! KYCWelcomeController

        navigationController.pushViewController(welcomeViewController, animated: true)
        navigationController.modalTransitionStyle = .coverVertical

        viewController.present(navigationController, animated: true)
    }
}
