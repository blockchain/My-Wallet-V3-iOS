//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DIKit
import FeatureAppDomain
import FeatureAuthenticationDomain
import FeatureBackupRecoveryPhraseUI
import FeatureDashboardUI
import FeatureOnboardingUI
import FeaturePin
import FeatureSuperAppIntroUI
import FeatureTransactionUI
import FeatureWalletConnectDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import StoreKit
import SwiftUI
import ToolKit
import UIKit

public final class MultiAppRootController: UIHostingController<MultiAppContainerChrome> {

    let app: AppProtocol
    let global: ViewStore<LoggedIn.State, LoggedIn.Action>

    let siteMap: SiteMap

    var appStoreReview: AnyCancellable?
    var displayPostSignInOnboardingFlow: AnyCancellable?
    var displaySendCryptoScreen: AnyCancellable?
    var displayPostSignUpOnboardingFlow: AnyCancellable?

    var bag: Set<AnyCancellable> = []

    // MARK: Dependencies

    @LazyInject var alertViewPresenter: AlertViewPresenterAPI
    @LazyInject var backupRouter: RecoveryPhraseBackupRouterAPI
    @LazyInject var coincore: CoincoreAPI
    @LazyInject var eligibilityService: EligibilityServiceAPI
    @LazyInject var featureFlagService: FeatureFlagsServiceAPI
    @LazyInject var fiatCurrencyService: FiatCurrencyServiceAPI
    @LazyInject var kycRouter: PlatformUIKit.KYCRouting
    @LazyInject var onboardingRouter: FeatureOnboardingUI.OnboardingRouterAPI
    @LazyInject var tiersService: KYCTiersServiceAPI
    @LazyInject var transactionsRouter: FeatureTransactionUI.TransactionsRouterAPI
    @Inject var walletConnectService: WalletConnectServiceAPI
    @Inject var walletConnectRouter: WalletConnectRouterAPI

    var pinRouter: PinRouter?

    lazy var bottomSheetPresenter = BottomSheetPresenting()

    public init(
        store global: Store<LoggedIn.State, LoggedIn.Action>,
        app: AppProtocol,
        siteMap: SiteMap
    ) {
        self.global = ViewStore(global)
        self.app = app
        self.siteMap = siteMap
        super.init(rootView: MultiAppContainerChrome(app: app))

        subscribeFrequentActions(to: app)

        setupNavigationObservers()
        observeDismissals()
    }

    public func clear() {
        bag.removeAll()
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribe(to: global)
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

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // The following fixes SwiftUI's gesture handling that can get messed up when applying
    // transforms and/or frame changes during an interactive presentation. This resets
    // SwiftUI's geometry in a "clean way", fixing hit testing.
    // source: https://github.com/nathantannar4/Transmission/blob/main/Sources/Transmission/Sources/View/PresentationLinkAdapter.swift#L397-L399
    private func observeDismissals() {
        alterDismissOnViewControllers()
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIApplication.keyboardDidHideNotification),
            NotificationCenter.default.publisher(for: UIViewController.controllerDidDismiss)
        )
        .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
            guard let self = self else {
                return
            }
            invalidateFrames(controller: self)
        }
        .store(in: &bag)
    }
}

extension MultiAppRootController {
    func subscribeFrequentActions(to app: AppProtocol) {

        Task {
            try await app.set(blockchain.ux.frequent.action.earn.then.enter.into, to: blockchain.ux.earn)
        }

        let observers = [
            app.on(blockchain.ux.frequent.action.swap) { [unowned self] _ in
                self.handleSwapCrypto(account: nil)
            },
            app.on(blockchain.ux.frequent.action.send) { [unowned self] _ in
                self.handleSendCrypto()
            },
            app.on(blockchain.ux.frequent.action.receive) { [unowned self] _ in
                self.handleReceiveCrypto()
            },
            app.on(blockchain.ux.frequent.action.rewards) { [unowned self] _ in
                self.handleRewards()
            },
            app.on(blockchain.ux.frequent.action.deposit) { [unowned self] _ in
                self.handleDeposit()
            },
            app.on(blockchain.ux.frequent.action.deposit.cash.identity.verification) { [unowned self] _ in
                self.showCashIdentityVerificationScreen()
            },
            app.on(blockchain.ux.frequent.action.withdraw) { [unowned self] _ in
                self.handleWithdraw()
            },
            app.on(blockchain.ux.frequent.action.buy) { [unowned self] _ in
                // No longer including an asset or account here so the user
                // can select what they want to buy prior to proceeding to the enter amount screen.
                self.handleBuyCrypto(account: nil)
            },
            app.on(blockchain.ux.frequent.action.sell) { [unowned self] _ in
                self.handleSellCrypto(account: nil)
            },
            app.on(blockchain.ux.frequent.action.nft) { [unowned self] _ in
                self.handleNFTAssetView()
            }
        ]

        for observer in observers {
            observer.subscribe().store(in: &bag)
        }
    }

    func subscribe(to viewStore: ViewStore<LoggedIn.State, LoggedIn.Action>) {
        displaySendCryptoScreen = viewStore.publisher
            .displaySendCryptoScreen
            .filter(\.self)
            .sink(to: My.handleSendCrypto, on: self)

        displayPostSignUpOnboardingFlow = viewStore.publisher
            .displayPostSignUpOnboardingFlow
            .filter(\.self)
            .delay(for: .seconds(4), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in
                // reset onboarding state
                viewStore.send(.didShowPostSignUpOnboardingFlow)
            })
            .sink(to: My.presentPostSignUpOnboarding, on: self)

        displayPostSignInOnboardingFlow = viewStore.publisher
            .displayPostSignInOnboardingFlow
            .filter(\.self)
            .delay(for: .seconds(4), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in
                // reset onboarding state
                viewStore.send(.didShowPostSignInOnboardingFlow)
            })
            .sink(to: My.presentPostSignInOnboarding, on: self)
    }
}

// MARK: - Frame invalidation

// The following fixes SwiftUI's gesture handling that can get messed up when applying
// transforms and/or frame changes during an interactive presentation. This resets
// SwiftUI's geometry in a clean way, fixing hit testing.
// source: https://github.com/nathantannar4/Transmission/blob/main/Sources/Transmission/Sources/View/PresentationLinkAdapter.swift#L397-L399

private func invalidateFrames(controller: UIViewController?) {
    if let presentingFrame = controller?.presentedViewController?.view {
        invalidateFrame(of: presentingFrame)
    }
    if let fromFrame = controller?.view {
        invalidateFrame(of: fromFrame)
    }
}

private func invalidateFrame(of view: UIView) {
    let frame = view.frame
    view.frame = .zero
    view.frame = frame
}
