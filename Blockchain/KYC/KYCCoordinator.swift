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
        let welcomeViewController = UIStoryboard.instantiate(
            child: KYCWelcomeController.self,
            from: KYCOnboardingController.self,
            in: UIStoryboard(name: "KYCOnboardingScreen", bundle: nil),
            identifier: "OnboardingScreen"
        )

        let navigationController = UIStoryboard(name: "KYCOnboardingNavigation", bundle: nil)
            .instantiateViewController(withIdentifier: "OnboardingNavigation") as! KYCOnboardingNavigationController

        navigationController.pushViewController(welcomeViewController, animated: true)
        navigationController.modalTransitionStyle = .coverVertical

        viewController.present(navigationController, animated: true)
    }

}
