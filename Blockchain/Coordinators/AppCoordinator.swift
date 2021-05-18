//
//  AppCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellUIKit
import DIKit
import InterestKit
import InterestUIKit
import KYCUIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import WalletPayloadKit

/// TODO: This class should be refactored so any view would load
/// as late as possible and also would be deallocated when is no longer in use
/// TICKET: https://blockchain.atlassian.net/browse/IOS-2619
@objc class AppCoordinator: NSObject, Coordinator, MainFlowProviding {
    
    // MARK: - Properties

    @Inject @objc static var shared: AppCoordinator

    // MARK: - Services
    
    /// Onboarding router
    @Inject var onboardingRouter: OnboardingRouter
    
    weak var window: UIWindow!

    @Inject private var authenticationCoordinator: AuthenticationCoordinator
    @Inject private var blockchainSettings: BlockchainSettings.App
    @Inject private var walletManager: WalletManager
    @Inject private var paymentPresenter: PaymentPresenter
    @Inject private var loadingViewPresenter: LoadingViewPresenting
    @LazyInject private var appFeatureConfigurator: AppFeatureConfigurator
    @LazyInject private var credentialsStore: CredentialsStoreAPI
    @LazyInject private var walletUpgradeService: WalletUpgradeServicing

    @Inject var airdropRouter: AirdropRouterAPI
    private var settingsRouterAPI: SettingsRouterAPI?
    private var buyRouter: BuySellUIKit.RouterAPI!
    private var sellRouter: BuySellUIKit.SellRouter!
    private var backupRouter: BackupRouterAPI?
    
    // MARK: - UIViewController Properties
    
    @objc var slidingViewController: ECSlidingViewController!
    @objc var tabControllerManager: TabControllerManager?
    private(set) var sideMenuViewController: SideMenuViewController!
    private let disposeBag = DisposeBag()
    
    private lazy var accountsAndAddressesNavigationController: AccountsAndAddressesNavigationController = { [unowned self] in
        let storyboard = UIStoryboard(name: "AccountsAndAddresses", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "AccountsAndAddressesNavigationController"
        ) as! AccountsAndAddressesNavigationController
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .coverVertical
        return viewController
    }()

    // MARK: NSObject

    override init() {
        super.init()
        self.walletManager.accountInfoAndExchangeRatesDelegate = self
        self.walletManager.backupDelegate = self
        self.walletManager.historyDelegate = self
        observeSymbolChanges()
    }

    // MARK: Public Methods

    /// Should be called only by Authentication after wallet loads.
    func startAfterWalletAuthentication() {
        guard let dismissible = window.rootViewController else {
            window.rootViewController = setupMainFlow()
            return
        }
        dismissible.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            // Sets view controller as rootViewController of the window
            self.window.rootViewController = self.setupMainFlow()
        }
    }

    func syncPinKeyWithICloud() {
        // In order to login to wallet, we need to know:
        // GUID                 - To look up the wallet
        // SharedKey            - To be able to read/write to the wallet db record (payload, settings, etc)
        // EncryptedPinPassword - To decrypt the wallet
        // PinKey               - Used in conjunction with the user's PIN to retrieve decryption key to the EncryptedPinPassword (EncryptedWalletPassword)
        // PIN                  - Provided by the user or retrieved from secure enclave if Face/TouchID is enabled

        // In this method, we backup/restore the pinKey - which is essentially the identifier of the PIN.
        // Upon successful PIN authentication, we will backup/restore the remaining wallet details: guid, sharedKey, encryptedPinPassword.
        // The backup/restore of guid and sharedKey requires an encryption/decryption step when backing up and restoring respectively.
        // The key used to encrypt/decrypt the guid and sharedKey is provided in the response to a successful PIN auth attempt.

        guard !blockchainSettings.isPairedWithWallet else {
            // Wallet is Paired, we do not need to restore.
            // We will back up after pin authentication
            return
        }

        if blockchainSettings.pinKey == nil,
            blockchainSettings.encryptedPinPassword == nil,
            blockchainSettings.guid == nil,
            blockchainSettings.sharedKey == nil {

            credentialsStore.synchronize()

            // Attempt to restore the pinKey from iCloud
            if let pinData = credentialsStore.pinData() {
                blockchainSettings.pinKey = pinData.pinKey
                blockchainSettings.encryptedPinPassword = pinData.encryptedPinPassword
            }
        }
    }
    
    @objc func start() {
        appFeatureConfigurator.initialize()

        // Try to restore wallet details from iCloud
        syncPinKeyWithICloud()

        if blockchainSettings.guid != nil, blockchainSettings.sharedKey != nil {
            // Original flow
            AuthenticationCoordinator.shared.start()
        } else if blockchainSettings.pinKey != nil, blockchainSettings.encryptedPinPassword != nil {
            // iCloud restoration flow
            AuthenticationCoordinator.shared.start()
        } else {
            onboardingRouter.start()
        }
    }

    @discardableResult
    func setupMainFlow() -> UIViewController {
        if walletUpgradeService.needsWalletUpgrade {
            return setupWalletUpgrade(completion: { [weak self] in
                guard let self = self else { return }
                self.window.rootViewController = self.setupLoggedInFlow()
            })
        } else {
            return setupLoggedInFlow()
        }
    }

    private func setupWalletUpgrade(completion: @escaping () -> Void) -> UIViewController {
        let interactor = WalletUpgradeInteractor(completion: completion)
        let presenter = WalletUpgradePresenter(interactor: interactor)
        let viewController = WalletUpgradeViewController(presenter: presenter)
        return viewController
    }

    private func setupLoggedInFlow() -> UIViewController {
        self.setupTabControllerManager()
        self.setupSideMenuViewController()
        let viewController = ECSlidingViewController()
        viewController.underLeftViewController = self.sideMenuViewController
        viewController.topViewController = self.tabControllerManager?.tabViewController
        self.slidingViewController = viewController
        self.tabControllerManager?.tabViewController.loadViewIfNeeded()
        self.tabControllerManager?.showDashboard()
        return viewController
    }

    private func setupSideMenuViewController() {
        let viewController = SideMenuViewController.makeFromStoryboard()
        viewController.delegate = self
        self.sideMenuViewController = viewController
    }
    
    private func setupTabControllerManager() {
        self.tabControllerManager = TabControllerManager()
    }

    func showSettingsView() {
        settingsRouterAPI = SettingsRouter(currencyRouting: self, tabSwapping: self)
        settingsRouterAPI?.presentSettings()
    }

    @objc func closeSideMenu() {
        guard let slidingViewController = slidingViewController else {
            return
        }
        guard slidingViewController.currentTopViewPosition != .centered else {
            return
        }
        slidingViewController.resetTopView(animated: true)
    }

    /// Reloads contained view controllers
    @objc func reload() {
        tabControllerManager?.reload()
        accountsAndAddressesNavigationController.reload()
        sideMenuViewController?.reload()
        
        NotificationCenter.default.post(name: Constants.NotificationKeys.reloadToDismissViews, object: nil)

        // Legacy code for generating new addresses
        NotificationCenter.default.post(name: Constants.NotificationKeys.newAddress, object: nil)
    }

    /// Method to "cleanup" state when the app is backgrounded.
    func cleanupOnAppBackgrounded() {
        
        /// Keep going only if the user is logged in
        guard slidingViewController != nil else {
            return
        }
        tabControllerManager?.hideSendAndReceiveKeyboards()
        tabControllerManager?.showDashboard()
        closeSideMenu()
    }

    /// Observes symbol changes so that view controllers can reflect the new symbol
    private func observeSymbolChanges() {
        BlockchainSettings.App.shared.onSymbolLocalChanged = { [unowned self] _ in
            self.tabControllerManager?.reloadSymbols()
            self.accountsAndAddressesNavigationController.reload()
            self.sideMenuViewController?.reload()
        }
    }

    func reloadAfterMultiAddressResponse() {
        guard tabControllerManager != nil, tabControllerManager!.tabViewController.isViewLoaded else {
            // Nothing to reload
            return
        }
        tabControllerManager?.reloadAfterMultiAddressResponse()
        accountsAndAddressesNavigationController.reload()
        sideMenuViewController?.reload()

        NotificationCenter.default.post(name: Constants.NotificationKeys.reloadToDismissViews, object: nil)
        NotificationCenter.default.post(name: Constants.NotificationKeys.newAddress, object: nil)
        NotificationCenter.default.post(name: Constants.NotificationKeys.multiAddressResponseReload, object: nil)
    }
}

extension AppCoordinator: SideMenuViewControllerDelegate {
    func sideMenuViewController(_ viewController: SideMenuViewController, didTapOn item: SideMenuItem) {
        switch item {
        case .backup:
            startBackupFlow()
        case .accountsAndAddresses:
            handleAccountsAndAddresses()
        case .settings:
            handleSettings()
        case .webLogin:
            handleWebLogin()
        case .support:
            handleSupport()
        case .airdrops:
            handleAirdrops()
        case .logout:
            handleLogout()
        case .buy:
            handleBuyCrypto()
        case .sell:
            handleSellCrypto()
        case .exchange:
            handleExchange()
        case .secureChannel:
            handleSecureChannel()
        case .lockbox:
            let lockboxViewController = LockboxViewController.makeFromStoryboard()
            lockboxViewController.modalPresentationStyle = .fullScreen
            lockboxViewController.modalTransitionStyle = .coverVertical
            UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(lockboxViewController, animated: true)
        }
    }

    private func handleAirdrops() {
        airdropRouter.presentAirdropCenterScreen()
    }

    private func handleSecureChannel() {
        // TODO: (paulo) Modern Wallet P3 - Show new QR code screen.
    }

    func startBackupFlow() {
        backupRouter = BackupFundsCustodialRouter()
        backupRouter?.start()
    }

    private func handleAccountsAndAddresses() {
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            accountsAndAddressesNavigationController,
            animated: true,
            completion: { [weak self] in
                self?.didPresentAccountsAndAddressesNavigationController()
            }
        )
    }

    private func didPresentAccountsAndAddressesNavigationController() {
        let wallet = walletManager.wallet
        guard wallet.didUpgradeToHd() else {
            fatalError("Wallet upgrade is not optional.")
        }
        guard accountsAndAddressesNavigationController.viewControllers.count == 1 else {
            return
        }
        guard wallet.getTotalBalanceForSpendableActiveLegacyAddresses() >= wallet.dust() else {
            return
        }
        guard accountsAndAddressesNavigationController.assetSelectorView().selectedAsset == .bitcoin else {
            return
        }
        accountsAndAddressesNavigationController.alertUserToTransferAllFunds()
    }

    private func handleSettings() {
        showSettingsView()
    }
    
    private func handleExchange() {
        guard let tabViewController = tabControllerManager?.tabViewController else { return }
        ExchangeCoordinator.shared.start(from: tabViewController)
    }

    private func handleWebLogin() {
        let presenter = WebLoginScreenPresenter()
        let viewController = WebLoginScreenViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        UIApplication.shared.topMostViewController?.present(
            navigationController,
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
                UIApplication.shared.open(url)
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
                AuthenticationCoordinator.shared.logout()
            }
        )
        alert.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel))
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
    }
    
    func clearOnLogout() {
        tabControllerManager = nil
        slidingViewController = nil
        sideMenuViewController = nil
    }

    /// Starts Buy Crypto flow.
    func handleBuyCrypto(currency: CryptoCurrency = .bitcoin) {
        let builder = BuySellUIKit.Builder(
            stateService: BuySellUIKit.StateService()
        )
        buyRouter = BuySellUIKit.Router(builder: builder, currency: currency)
        buyRouter.start()
    }
    
    /// Starts Sell Crypto flow
    @objc func handleSellCrypto() {
        let accountSelectionService = AccountSelectionService()
        let interactor = SellRouterInteractor(
            accountSelectionService: accountSelectionService,
            balanceProvider: DataProvider.default.balance
        )
        let builder = BuySellUIKit.SellBuilder(
            accountSelectionService: accountSelectionService,
            routerInteractor: interactor,
            analyticsRecorder: resolve(),
            balanceProvider: DataProvider.default.balance
        )
        sellRouter = BuySellUIKit.SellRouter(builder: builder)
        sellRouter.load()
    }
    
    func startSimpleBuyAtLogin() {
        let stateService = BuySellUIKit.StateService()
        guard !stateService.cache[.hasShownIntroScreen] else {
            return
        }
        
        let builder = BuySellUIKit.Builder(
            stateService: stateService
        )
        
        buyRouter = BuySellUIKit.Router(builder: builder)
        buyRouter.start()
    }
    
    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool) {
        let stateService = BuySellUIKit.StateService()
        let builder = BuySellUIKit.Builder(
            stateService: stateService
        )
        
        buyRouter = BuySellUIKit.Router(builder: builder)
        buyRouter.setup(startImmediately: false)
        stateService.showFundsTransferDetails(
            for: fiatCurrency,
            isOriginDeposit: isOriginDeposit
        )
    }
}

// MARK: - DrawerRouting

extension AppCoordinator: DrawerRouting {
    // Shows the side menu (i.e. ECSlidingViewController)
    @objc func toggleSideMenu() {
        // If the sideMenu is not shown, show it
        if slidingViewController.currentTopViewPosition == .centered {
            slidingViewController.anchorTopViewToRight(animated: true)
        } else {
            slidingViewController.resetTopView(animated: true)
        }
    }
}

extension AppCoordinator: WalletAccountInfoAndExchangeRatesDelegate {
    func didGetAccountInfoAndExchangeRates() {
        loadingViewPresenter.hide()
        reloadAfterMultiAddressResponse()
    }
}

extension AppCoordinator: WalletBackupDelegate {
    func didBackupWallet() {
        walletManager.wallet.getHistoryForAllAssets()
    }

    func didFailBackupWallet() {
        walletManager.wallet.getHistoryForAllAssets()
    }
}

extension AppCoordinator: WalletHistoryDelegate {
    func didFailGetHistory(error: String?) {
        guard let errorMessage = error, errorMessage.count > 0 else {
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.noInternetConnectionPleaseCheckNetwork)
            return
        }
        AnalyticsService.shared.trackEvent(title: "btc_history_error", parameters: ["error": errorMessage])
        AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.balancesGeneric)
    }

    func didFetchBitcoinCashHistory() {
        loadingViewPresenter.hide()
        reload()
    }
}

// MARK: - TabSwapping

extension AppCoordinator: TabSwapping {
    
    func send(from account: BlockchainAccount) {
        tabControllerManager?.send(from: account)
    }
    
    func switchToSend() {
        tabControllerManager?.showSend()
    }
    
    func switchTabToSwap() {
        tabControllerManager?.showSwap()
    }
    
    func switchTabToReceive() {
        tabControllerManager?.showReceive()
    }
    
    func switchToActivity(currency: CryptoCurrency) {
        tabControllerManager?.showTransactions()
    }
}

extension AppCoordinator: CurrencyRouting {
    func toSend(_ currency: CryptoCurrency) {
        tabControllerManager?.showSend(cryptoCurrency: currency)
    }
    
    func toReceive(_ currency: CryptoCurrency) {
        tabControllerManager?.showReceive()
    }
}

extension AppCoordinator: CashIdentityVerificationAnnouncementRouting {
    func showCashIdentityVerificationScreen() {
        let presenter = CashIdentityVerificationPresenter()
        let controller = CashIdentityVerificationViewController(presenter: presenter)
        tabControllerManager?.tabViewController.showCashIdentityVerificatonController(controller)
    }
}

extension AppCoordinator: InterestIdentityVerificationAnnouncementRouting {
    func showInterestDashboardAnnouncementScreen(isKYCVerfied: Bool) {
        var presenter: InterestDashboardAnnouncementPresenting
        let router = InterestDashboardAnnouncementRouter(
            navigationRouter: NavigationRouter()
        )
        if isKYCVerfied {
            presenter = InterestDashboardAnnouncementScreenPresenter(
                router: router
            )
        } else {
            presenter = InterestIdentityVerificationScreenPresenter(
                router: router
            )
        }
        let controller = InterestDashboardAnnouncementViewController(presenter: presenter)
        tabControllerManager?.tabViewController.showInterestIdentityVerificationScreen(controller)
    }
}

// MARK: - DevSupporting

extension AppCoordinator: DevSupporting {
    @objc func showDebugView(from presenter: DebugViewPresenter) {
        let debugViewController = DebugTableViewController()
        debugViewController.presenter = presenter
        let navigationController = UINavigationController(rootViewController: debugViewController)
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(navigationController, animated: true)
    }
}
