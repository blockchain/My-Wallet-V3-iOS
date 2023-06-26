//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureAppDomain
import FeatureAppUI
import FeatureAuthenticationDomain
import FeatureBackupRecoveryPhraseUI
import FeatureDashboardUI
import FeatureOnboardingUI
import FeaturePin
import FeatureTransactionUI
import FeatureWalletConnectDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import StoreKit
import SwiftUI
import ToolKit

final class RootViewController: UIHostingController<RootView> {

    let viewStore: ViewStore<RootViewState, RootViewAction>
    let global: ViewStore<LoggedIn.State, LoggedIn.Action>

    var defaults: CacheSuite = UserDefaults.standard
    var application: UIApplication = .shared

    var siteMap: SiteMap

    var appStoreReview: AnyCancellable?
    var bag: Set<AnyCancellable> = []

    init(store global: Store<LoggedIn.State, LoggedIn.Action>, siteMap: SiteMap) {

        self.global = ViewStore(global)
        self.siteMap = siteMap

        let environment = RootViewEnvironment(
            app: app,
            backupFundsRouter: resolve(),
            coincore: resolve(),
            recoveryPhraseStatusProviding: resolve(),
            analyticsRecoder: resolve()
        )

        let store = Store(
            initialState: RootViewState(
                fab: .init(
                    animate: !defaults.hasInteractedWithFrequentActionButton
                ),
                referralState: .init(
                    isHighlighted: false,
                    referral: nil
                )
            ),
            reducer: rootMainReducer,
            environment: environment
        )

        self.viewStore = ViewStore(store)
        self.siteMap = SiteMap(app: app)

        super.init(rootView: RootView(store: store, siteMap: siteMap))

        subscribe(to: ViewStore(global))
        subscribe(to: app)

        if !defaults.hasInteractedWithFrequentActionButton {
            environment.publisher
                .map(\.state.fab.isOn)
                .first(where: \.self)
                .sink(to: My.handleFirstFrequentActionButtonInteraction, on: self)
                .store(in: &bag)
        }

        setupNavigationObservers()
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }

    func clear() {
        bag.removeAll()
    }

    // MARK: Dependencies

    @LazyInject var alertViewPresenter: AlertViewPresenterAPI
    @LazyInject var backupRouter: RecoveryPhraseBackupRouterAPI
    @LazyInject var coincore: CoincoreAPI
    @LazyInject var eligibilityService: EligibilityServiceAPI
    @LazyInject var fiatCurrencyService: FiatCurrencyServiceAPI
    @LazyInject var kycRouter: PlatformUIKit.KYCRouting
    @LazyInject var onboardingRouter: FeatureOnboardingUI.OnboardingRouterAPI
    @LazyInject var tiersService: KYCTiersServiceAPI
    @LazyInject var transactionsRouter: FeatureTransactionUI.TransactionsRouterAPI
    @Inject var walletConnectService: WalletConnectServiceAPI
    @Inject var walletConnectRouter: WalletConnectRouterAPI

    var pinRouter: PinRouter?

    lazy var bottomSheetPresenter = BottomSheetPresenting()
}

extension RootViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appStoreReview = NotificationCenter.default.publisher(for: .transaction)
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let scene = self?.view.window?.windowScene else { return }
                #if INTERNAL_BUILD
                scene.peek("🧾 Show App Store Review Prompt!")
                #else
                SKStoreReviewController.requestReview(in: scene)
                #endif
            }
    }
}

extension RootViewController {

    func subscribe(to app: AppProtocol) {

        Task {
            try await app.set(blockchain.ux.frequent.action.earn.then.enter.into, to: blockchain.ux.earn)
        }

        let observers = [
            app.on(blockchain.ux.frequent.action.swap) { [unowned self] _ in
                handleSwapCrypto(account: nil)
            },
            app.on(blockchain.ux.frequent.action.send) { [unowned self] _ in
                handleSendCrypto()
            },
            app.on(blockchain.ux.frequent.action.receive) { [unowned self] _ in
                handleReceiveCrypto()
            },
            app.on(blockchain.ux.frequent.action.rewards) { [unowned self] _ in
                handleRewards()
            },
            app.on(blockchain.ux.frequent.action.deposit) { [unowned self] _ in
                handleDeposit()
            },
            app.on(blockchain.ux.frequent.action.withdraw) { [unowned self] _ in
                handleWithdraw()
            },
            app.on(blockchain.ux.frequent.action.deposit.cash.identity.verification) { [unowned self] _ in
                showCashIdentityVerificationScreen()
            },
            app.on(blockchain.ux.frequent.action.buy) { [unowned self] _ in
                // No longer including an asset or account here so the user
                // can select what they want to buy prior to proceeding to the enter amount screen.
                handleBuyCrypto(account: nil)
            },
            app.on(blockchain.ux.frequent.action.sell) { [unowned self] _ in
                handleSellCrypto(account: nil)
            },
            app.on(blockchain.ux.frequent.action.nft) { [unowned self] _ in
                handleNFTAssetView()
            },
            app.on(blockchain.ux.home.tab.select) { @MainActor [unowned self] _ async in
                self.dismiss(animated: true)
            }
        ]

        for observer in observers {
            observer.subscribe().store(in: &bag)
        }

        app.on(where: isDescendant(of: blockchain.ux.frequent.action))
            .sink { [weak self] _ in
                guard let viewStore = self?.viewStore else { return }
                viewStore.send(.binding(.set(\.$fab.isOn, false)), animation: .linear)
            }
            .store(in: &bag)
    }

    func subscribe(to viewStore: ViewStore<LoggedIn.State, LoggedIn.Action>) {

        viewStore.publisher
            .displaySendCryptoScreen
            .filter(\.self)
            .sink(to: My.handleSendCrypto, on: self)
            .store(in: &bag)

        viewStore.publisher
            .displayPostSignUpOnboardingFlow
            .filter(\.self)
            .handleEvents(receiveOutput: { _ in
                // reset onboarding state
                viewStore.send(.didShowPostSignUpOnboardingFlow)
            })
            .sink(to: My.presentPostSignUpOnboarding, on: self)
            .store(in: &bag)
    }
}

extension RootViewController {

    func handleFirstFrequentActionButtonInteraction() {
        defaults.hasInteractedWithFrequentActionButton = true
    }
}

extension CacheSuite {

    var hasInteractedWithFrequentActionButton: Bool {
        get { bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
