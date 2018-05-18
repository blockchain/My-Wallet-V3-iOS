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

    // MARK: - Properties

    private(set) var window: UIWindow

    private let walletManager: WalletManager

    // MARK: - UIViewController Properties

    @objc lazy var slidingViewController: ECSlidingViewController = { [unowned self] in
        let viewController = ECSlidingViewController()
        viewController.underLeftViewController = self.sideMenuViewController
        viewController.topViewController = tabControllerManager.tabViewController
        return viewController
    }()

    @objc lazy var tabControllerManager: TabControllerManager = { [unowned self] in
        let tabControllerManager = TabControllerManager()
        tabControllerManager.delegate = self
        return tabControllerManager
    }()

    private lazy var sideMenuViewController: SideMenuViewController = { [unowned self] in
        let sideMenu = SideMenuViewController()
        sideMenu.delegate = self
        return sideMenu
    }()

    private lazy var accountsAndAddressesNavigationController: AccountsAndAddressesNavigationController = { [unowned self] in
        let storyboard = UIStoryboard(name: "AccountsAndAddresses", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "AccountsAndAddressesNavigationController"
        ) as! AccountsAndAddressesNavigationController
        viewController.modalTransitionStyle = .coverVertical
        return viewController
    }()

    private lazy var settingsNavigationController: SettingsNavigationController = { [unowned self] in
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "SettingsNavigationController"
        ) as! SettingsNavigationController
        viewController.showSettings()
        viewController.modalTransitionStyle = .coverVertical
        return viewController
    }()

    private var buyBitcoinViewController: BuyBitcoinViewController?

    // MARK: NSObject

    private init(walletManager: WalletManager = WalletManager.shared) {
        self.walletManager = walletManager
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.backgroundColor = UIColor.white
        super.init()
        self.walletManager.buySellDelegate = self
        self.walletManager.accountInfoAndExchangeRatesDelegate = self
        observeSymbolChanges()
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
        guard !walletManager.wallet.didUpgradeToHd() else { return }
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

    @objc func showBackupView() {
        let storyboard = UIStoryboard(name: "Backup", bundle: nil)
        let backupController = storyboard.instantiateViewController(withIdentifier: "BackupNavigation") as! BackupNavigationViewController
        backupController.wallet = walletManager.wallet
        backupController.modalTransitionStyle = .coverVertical
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(backupController, animated: true)
    }

    @objc func showSettingsView(completion: ((_ settingViewController: SettingsNavigationController) -> Void)? = nil) {
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            settingsNavigationController,
            animated: true
        ) { [weak self] in
            guard let strongSelf = self else { return }
            completion?(strongSelf.settingsNavigationController)
        }
    }

    @objc func showBuyBitcoinView() {
        guard let buyBitcoinViewController = buyBitcoinViewController else {
            print("buyBitcoinViewController not yet initialized")
            return
        }

        // TODO convert this dictionary into a model
        guard let loginDataDict = walletManager.wallet.executeJSSynchronous(
            "MyWalletPhone.getWebViewLoginData()"
            ).toDictionary() else {
                print("loginData from wallet is empty")
                return
        }

        guard let walletJson = loginDataDict["walletJson"] as? String else {
            print("walletJson is nil")
            return
        }

        guard let externalJson = loginDataDict["externalJson"] is NSNull ? "" : loginDataDict["externalJson"] as? String else {
            print("externalJson is nil")
            return
        }

        guard let magicHash = loginDataDict["magicHash"] is NSNull ? "" : loginDataDict["magicHash"] as? String else {
            print("magicHash is nil")
            return
        }

        buyBitcoinViewController.login(
            withJson: walletJson,
            externalJson: externalJson,
            magicHash: magicHash,
            password: walletManager.wallet.password
        )
        buyBitcoinViewController.delegate = walletManager.wallet // TODO fix this

        guard let navigationController = BuyBitcoinNavigationController(
            rootViewController: buyBitcoinViewController,
            title: LocalizationConstants.SideMenu.buySellBitcoin
            ) else {
                return
        }

        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            navigationController,
            animated: true
        )
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
        settingsNavigationController.reload()
        accountsAndAddressesNavigationController.reload()

        if let sideMenuViewController = slidingViewController.underLeftViewController as? SideMenuViewController {
            sideMenuViewController.reload()
        }

        NotificationCenter.default.post(name: Constants.NotificationKeys.reloadToDismissViews, object: nil)

        // Legacy code for generating new addresses
        NotificationCenter.default.post(name: Constants.NotificationKeys.newAddress, object: nil)
    }

    /// Method to "cleanup" state when the app is backgrounded.
    func cleanupOnAppBackgrounded() {
        tabControllerManager.hideSendAndReceiveKeyboards()
        tabControllerManager.transactionsBitcoinViewController?.loadedAllTransactions = false
        tabControllerManager.transactionsBitcoinViewController?.messageIdentifier = nil

        closeSideMenu()
    }

    /// Observes symbol changes so that view controllers can reflect the new symbol
    private func observeSymbolChanges() {
        BlockchainSettings.App.shared.onSymbolLocalChanged = { [unowned self] _ in
            self.tabControllerManager.reloadSymbols()
            self.accountsAndAddressesNavigationController.reload()
            self.sideMenuViewController.reload()
        }
    }
}

extension AppCoordinator: SideMenuViewControllerDelegate {
    func onSideMenuItemTapped(_ identifier: String!) {
        guard let sideMenuItem = SideMenuItem(rawValue: identifier) else {
            print("Unrecognized SideMenuItem with identifier: \(identifier)")
            return
        }

        switch sideMenuItem {
        case .upgradeBackup:
            handleUpgradeBackup()
        case .accountsAndAddresses:
            handleAccountsAndAddresses()
        case .settings:
            handleSettings()
        case .webLogin:
            handleWebLogin()
        case .support:
            handleSupport()
        case .logout:
            handleLogout()
        case .buyBitcoin:
            handleBuyBitcoin()
        case .exchange:
            handleExchange()
        }
    }

    private func handleUpgradeBackup() {
        if walletManager.wallet.didUpgradeToHd() {
            showBackupView()
        } else {
            AppCoordinator.shared.showHdUpgradeView()
        }
    }

    private func handleAccountsAndAddresses() {
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            accountsAndAddressesNavigationController,
            animated: true
        ) { [weak self] in
            guard let strongSelf = self else { return }

            let wallet = strongSelf.walletManager.wallet

            guard !BlockchainSettings.App.shared.hideTransferAllFundsAlert &&
                strongSelf.accountsAndAddressesNavigationController.viewControllers.count == 1 &&
                wallet.didUpgradeToHd() &&
                wallet.getTotalBalanceForSpendableActiveLegacyAddresses() >= wallet.dust() &&
                strongSelf.accountsAndAddressesNavigationController.assetSelectorView.selectedAsset == .bitcoin else {
                    return
            }

            strongSelf.accountsAndAddressesNavigationController.alertUser(toTransferAllFunds: false)
        }
    }

    private func handleSettings() {
        showSettingsView()
    }

    private func handleWebLogin() {
        let webLoginViewController = WebLoginViewController()
        guard let navigationViewController = BCNavigationController(
            rootViewController: webLoginViewController,
            title: LocalizationConstants.SideMenu.loginToWebWallet
        ) else { return }
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            navigationViewController,
            animated: true
        )
    }

    private func handleSupport() {
        let title = String(format: LocalizationConstants.openArg, Constants.Url.blockchainSupport)
        let alert = UIAlertController(
            title: title,
            message: LocalizationConstants.youWillBeLeavingTheApp,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
                guard let url = URL(string: Constants.Url.blockchainSupport) else { return }
                UIApplication.shared.openURL(url)
            }
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        )
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
    }

    private func handleLogout() {
        let alert = UIAlertController(
            title: LocalizationConstants.SideMenu.logout,
            message: LocalizationConstants.SideMenu.logoutConfirm,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.okString, style: .default) { _ in
                AuthenticationCoordinator.shared.logout(showPasswordView: true)
            }
        )
        alert.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel))
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
    }

    private func handleBuyBitcoin() {
        showBuyBitcoinView()
    }

    private func handleExchange() {
        tabControllerManager.exchangeClicked()
    }
}

extension AppCoordinator: WalletBuySellDelegate {
    func initializeWebView() {
        buyBitcoinViewController = BuyBitcoinViewController()
    }

    func didCompleteTrade(trade: Trade) {
        let actions = [UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil),
                       UIAlertAction(title: LocalizationConstants.BuySell.viewDetails, style: .default, handler: { _ in
                        AppCoordinator.shared.tabControllerManager.showTransactionDetail(forHash: trade.hash)
                       })]
        AlertViewPresenter.shared.standardNotify(message: String(format: LocalizationConstants.BuySell.tradeCompletedDetailArg, trade.date),
                                          title: LocalizationConstants.BuySell.tradeCompleted,
                                          actions: actions)
    }

    func showCompletedTrade(tradeHash: String) {
        AppCoordinator.shared.closeSideMenu()
        AppCoordinator.shared.tabControllerManager.showTransactions(animated: true)
        AppCoordinator.shared.tabControllerManager.showTransactionDetail(forHash: tradeHash)
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
        walletManager.wallet.isFetchingTransactions = false
    }
}

extension AppCoordinator: WalletAccountInfoAndExchangeRatesDelegate {
    func didGetAccountInfoAndExchangeRates() {
        LoadingViewPresenter.shared.hideBusyView()
        reload()
    }
}
