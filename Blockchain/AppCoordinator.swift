//
//  AppCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AppCoordinator: NSObject {
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

        // Display welcome screen if no wallet is authenticated
        if KeychainItemWrapper.guid() == nil || KeychainItemWrapper.sharedKey() == nil {
            // TODO start onboarding coordinator
        } else {
            // TODO otherwise, show pin screen
        }
    }

    @objc func showDebugView(presenter: Int32) {
        let debugViewController = DebugTableViewController()
        debugViewController.presenter = presenter
        let navigationController = UINavigationController(rootViewController: debugViewController)
        window.rootViewController?.present(navigationController, animated: true)
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

        // TODO remove app reference and use wallet singleton
        app.wallet.isFetchingTransactions = false
    }
}
