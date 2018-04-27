//
//  AppCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 Application coordinator.

 This Singleton coordinator is in charge of coordinating the set of views that are
 presented when the app first launches.
*/
@objc class AppCoordinator: NSObject, Coordinator {
    static let shared = AppCoordinator()

    // class function declared so that the AppCoordinator singleton can be accessed from obj-C
    @objc class func sharedInstance() -> AppCoordinator {
        return AppCoordinator.shared
    }

    // MARK: Properties

    private(set) var window: UIWindow

    @objc lazy var slidingViewController: ECSlidingViewController = {
        let viewController = ECSlidingViewController()
        viewController.underLeftViewController = SideMenuViewController()
        viewController.topViewController = tabControllerManager.tabViewController
        return viewController
    }()

    @objc lazy var tabControllerManager: TabControllerManager = { [unowned self] in
        let tabControllerManager = TabControllerManager()
        tabControllerManager.delegate = self
        return tabControllerManager
    }()

    // MARK: NSObject

    override private init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        super.init()
    }

    // MARK: Public Methods

    @objc func start() {
        // Set rootViewController
        window.rootViewController = slidingViewController
        window.makeKeyAndVisible()
        tabControllerManager.dashBoardClicked(nil)

        // Add busy view
        LoadingViewPresenter.shared.initialize()

        // Display welcome screen if no wallet is authenticated
        if BlockchainSettings.App.shared.guid == nil || BlockchainSettings.App.shared.sharedKey == nil {
            OnboardingCoordinator.shared.start()
        } else {
            AuthenticationCoordinator.shared.start()
        }
    }

    /// Shows an upgrade to HD wallet prompt if the user has a legacy wallet
    @objc func showHdUpgradeViewIfNeeded() {
        guard !WalletManager.shared.wallet.didUpgradeToHd() else { return }
        showHdUpgradeView()
    }

    /// Shows the HD wallet upgrade view
    @objc func showHdUpgradeView() {
        let storyboard = UIStoryboard(name: "Upgrade", bundle: nil)
        let upgradeViewController = storyboard.instantiateViewController(withIdentifier: "UpgradeViewController")
        upgradeViewController.modalTransitionStyle = .coverVertical
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            upgradeViewController,
            animated: true
        )
    }

    @objc func showDebugView(presenter: Int32) {
        let debugViewController = DebugTableViewController()
        debugViewController.presenter = presenter
        let navigationController = UINavigationController(rootViewController: debugViewController)
        window.rootViewController?.present(navigationController, animated: true)
    }

    @objc func closeSideMenu() {
        guard slidingViewController.currentTopViewPosition != .centered else {
            return
        }
        slidingViewController.resetTopView(animated: true)
    }

    /// Reloads contained view controllers
    @objc func reload() {
        tabControllerManager.reload()

        // TODO: reload these view controllers as well
//        [_settingsNavigationController reload];
//        [_accountsAndAddressesNavigationController reload];

        if let sideMenuViewController = slidingViewController.underLeftViewController as? SideMenuViewController {
            sideMenuViewController.reload()
        }

        NotificationCenter.default.post(name: Constants.NotificationKeys.reloadToDismissViews, object: nil)

        // Legacy code for generating new addresses
        NotificationCenter.default.post(name: Constants.NotificationKeys.newAddress, object: nil)
    }
}

extension AppCoordinator: TabControllerDelegate {
    func toggleSideMenu() {
        // If the sideMenu is not shown, show it
        if slidingViewController.currentTopViewPosition == .centered {
            slidingViewController.anchorTopViewToRight(animated: true)
        } else {
            slidingViewController.resetTopView(animated: true)
        }

        // TODO remove app reference and use wallet singleton.isFe
        WalletManager.shared.wallet.isFetchingTransactions = false
    }
}
