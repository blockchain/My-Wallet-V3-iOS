// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DashboardUIKit
import DIKit
import InterestUIKit
import PlatformKit
import PlatformUIKit
import SettingsUIKit
import ToolKit

/// Acts as a container for the Home screen
final class LoggedInHostingController: UIViewController, LoggedInBridge {

    let store: Store<LoggedIn.State, LoggedIn.Action>
    let viewStore: ViewStore<LoggedIn.State, LoggedIn.Action>
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - The controllers
    var sideMenuViewController: SideMenuViewController?
    var tabControllerManager: TabControllerManager?
    var slidingViewController: ECSlidingViewController?

    weak var accountsAndAddressesNavigationController: AccountsAndAddressesNavigationController?

    @LazyInject var alertViewPresenter: AlertViewPresenterAPI
    @LazyInject var secureChannelRouter: SecureChannelRouting
    @Inject var airdropRouter: AirdropRouterAPI

    var settingsRouterAPI: SettingsRouterAPI?
    var buyRouter: PlatformUIKit.RouterAPI!
    var sellRouter: PlatformUIKit.SellRouter!
    var backupRouter: DashboardUIKit.BackupRouterAPI?
    var pinRouter: PinRouter?

    @LazyInject var transactionsAdapter: TransactionsAdapterAPI

    init(store: Store<LoggedIn.State, LoggedIn.Action>) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewStore.publisher
            .reloadAfterMultiAddressResponse
            .filter { $0 }
            .sink { [weak self] _ in
                self?.reloadAfterMultiAddressResponse()
            }
            .store(in: &cancellables)

        viewStore.publisher
            .reloadAfterSymbolChanged
            .filter { $0 }
            .sink { [weak self] _ in
                self?.accountsAndAddressesNavigationController?.reload()
                self?.sideMenuViewController?.reload()
            }
            .store(in: &cancellables)

        viewStore.publisher
            .displayWalletAlertContent
            .compactMap { $0 }
            .removeDuplicates()
            .sink {[weak self] content in
                self?.showAlert(with: content)
            }
            .store(in: &cancellables)

        let sideMenu = sideMenuProvider()
        let tabController = tabControllerProvider()
        let slidingViewController = slidingControllerProvider(sideMenuController: sideMenu, tabController: tabController)
        add(child: slidingViewController)
        self.slidingViewController = slidingViewController
        sideMenuViewController = sideMenu
        tabControllerManager = tabController

        sideMenuViewController?.tabControllerManager = tabControllerManager
        sideMenuViewController?.slidingViewController = slidingViewController
    }

    func clear() {
        cancellables.forEach { $0.cancel() }
        sideMenuViewController?.delegate = nil
        sideMenuViewController?.createGestureRecognizers = nil
        sideMenuViewController = nil
        tabControllerManager = nil
        slidingViewController?.remove()
        slidingViewController = nil
    }

    // MARK: Private

    private func sideMenuProvider() -> SideMenuViewController {
        let sideMenuController = SideMenuViewController.makeFromStoryboard()
        sideMenuController.delegate = self
        sideMenuController.createGestureRecognizers = { [weak self] in
            guard let self = self else { return nil }
            return (
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(Self.toggleSideMenu)
                ),
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(Self.toggleSideMenu)
                )
            )
        }
        return sideMenuController
    }

    private func tabControllerProvider() -> TabControllerManager {
        TabControllerManager()
    }

    private func slidingControllerProvider(sideMenuController: SideMenuViewController?,
                                           tabController: TabControllerManager?) -> ECSlidingViewController {
        let viewController = ECSlidingViewController()
        // Assign the required controllers
        viewController.underLeftViewController = sideMenuController
        viewController.topViewController = tabController?.tabViewController
        // Configure the main controller
        tabController?.tabViewController.sideMenuGesture = viewController.panGesture
        tabController?.tabViewController.loadViewIfNeeded()
        // Configure side menu controller
        sideMenuController?.peekPadding = viewController.anchorRightPeekAmount
        // Show dashboard as the default screen
        tabController?.showDashboard()
        return viewController
    }

    private func showAlert(with content: AlertViewContent) {
        alertViewPresenter.notify(content: content, in: self)
    }

    // MARK: AuthenticationCoordinating

    func enableBiometrics() {
        guard let slidingViewController = slidingViewController else {
            return
        }
        let logout = { [weak self] () -> Void in
            self?.viewStore.send(.logout)
        }
        let boxedParent = UnretainedContentBox<UIViewController>(slidingViewController.topMostViewController)
        let flow = PinRouting.Flow.enableBiometrics(parent: boxedParent, logoutRouting: logout)
        pinRouter = PinRouter(flow: flow) { [weak self] input in
            guard let password = input.password else { return }
            self?.viewStore.send(.wallet(.authenticateForBiometrics(password: password)))
            self?.pinRouter = nil
        }
        pinRouter?.execute()
    }

    func changePin() {
        guard let slidingViewController = slidingViewController else {
            return
        }
        let logout = { [weak self] () -> Void in
            self?.viewStore.send(.logout)
        }
        let boxedParent = UnretainedContentBox<UIViewController>(slidingViewController.topMostViewController)
        let flow = PinRouting.Flow.change(parent: boxedParent, logoutRouting: logout)
        pinRouter = PinRouter(flow: flow) { [weak self] _ in
            self?.pinRouter = nil
        }
        pinRouter?.execute()
    }
}

extension LoggedInHostingController: SideMenuViewControllerDelegate {
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
            break
        }
    }

    // MARK: - LoggedInReloadAPI
    func reload() {
        accountsAndAddressesNavigationController?.reload()
        sideMenuViewController?.reload()

        NotificationCenter.default.post(
            name: Constants.NotificationKeys.reloadToDismissViews,
            object: nil
        )

        // Legacy code for generating new addresses
        NotificationCenter.default.post(
            name: Constants.NotificationKeys.newAddress,
            object: nil
        )
    }
}

extension LoggedInHostingController {
    @objc // needed as we use this for gesture recognizers
    func toggleSideMenu() {
        // If the sideMenu is not shown, show it
        if slidingViewController?.currentTopViewPosition == .centered {
            slidingViewController?.anchorTopViewToRight(animated: true)
        } else {
            slidingViewController?.resetTopView(animated: true)
        }
    }

    func closeSideMenu() {
        guard let slidingViewController = slidingViewController else {
            return
        }
        guard slidingViewController.currentTopViewPosition != .centered else {
            return
        }
        slidingViewController.resetTopView(animated: true)
    }

    func showSettingsView() {
        let router: SettingsRouterAPI = resolve()
        settingsRouterAPI = router
        router.presentSettings()
    }

    // MARK: - TabSwapping

    func deposit(into account: BlockchainAccount) {
        tabControllerManager?.deposit(into: account)
    }

    func withdraw(from account: BlockchainAccount) {
        tabControllerManager?.withdraw(from: account)
    }

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

    func switchToActivity() {
        tabControllerManager?.showTransactions()
    }

    func switchToActivity(for currencyType: CurrencyType) {
        tabControllerManager?.showTransactions()
    }

    // MARK: - CurrencyRouting

    func toSend(_ currency: CurrencyType) {
        tabControllerManager?.showSend(cryptoCurrency: currency.cryptoCurrency!)
    }

    func toReceive(_ currency: CurrencyType) {
        tabControllerManager?.showReceive()
    }

    // MARK: - CashIdentityVerificationAnnouncementRouting

    func showCashIdentityVerificationScreen() {
        let presenter = CashIdentityVerificationPresenter()
        let controller = CashIdentityVerificationViewController(presenter: presenter)
        tabControllerManager?.tabViewController.showCashIdentityVerificatonController(controller)
    }

    // MARK: - InterestIdentityVerificationAnnouncementRouting

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

    func reloadAfterMultiAddressResponse() {
        guard let tabControllerManager = tabControllerManager, tabControllerManager.tabViewController.isViewLoaded else {
            // Nothing to reload
            return
        }
        accountsAndAddressesNavigationController?.reload()
        sideMenuViewController?.reload()

        NotificationCenter.default.post(name: Constants.NotificationKeys.reloadToDismissViews, object: nil)
        NotificationCenter.default.post(name: Constants.NotificationKeys.newAddress, object: nil)
        NotificationCenter.default.post(name: Constants.NotificationKeys.multiAddressResponseReload, object: nil)
    }
}
