// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import FeatureActivityUI
import FeatureDashboardUI
import protocol FeatureOnboardingUI.OnboardingRouterAPI
import FeatureReferralDomain
import FeatureReferralUI
import FeatureSettingsUI
import FeatureTransactionDomain
import FeatureTransactionUI
import FeatureWalletConnectDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit
import UIKit

public final class DeepLinkCoordinator: Client.Observer {

    private let app: AppProtocol
    private let coincore: CoincoreAPI
    private let exchangeProvider: ExchangeProviding
    private let kycRouter: KYCRouting
    private let payloadFactory: CryptoTargetPayloadFactoryAPI
    private let window: TopMostViewControllerProviding
    private let transactionsRouter: TransactionsRouterAPI
    private let paymentMethodLinker: PaymentMethodsLinkerAPI
    private let analyticsRecording: AnalyticsEventRecorderAPI
    private let onboardingRouter: OnboardingRouterAPI
    private let walletConnectService: () -> WalletConnectVersionRouter

    private var bag: Set<AnyCancellable> = []

    init(
        app: AppProtocol,
        coincore: CoincoreAPI,
        exchangeProvider: ExchangeProviding,
        kycRouter: KYCRouting,
        payloadFactory: CryptoTargetPayloadFactoryAPI,
        topMostViewControllerProvider: TopMostViewControllerProviding,
        transactionsRouter: TransactionsRouterAPI,
        paymentMethodLinker: PaymentMethodsLinkerAPI = resolve(),
        analyticsRecording: AnalyticsEventRecorderAPI,
        walletConnectService: @escaping () -> WalletConnectVersionRouter,
        onboardingRouter: OnboardingRouterAPI
    ) {
        self.app = app
        self.coincore = coincore
        self.exchangeProvider = exchangeProvider
        self.kycRouter = kycRouter
        self.payloadFactory = payloadFactory
        self.window = topMostViewControllerProvider
        self.transactionsRouter = transactionsRouter
        self.analyticsRecording = analyticsRecording
        self.walletConnectService = walletConnectService
        self.onboardingRouter = onboardingRouter
        self.paymentMethodLinker = paymentMethodLinker
    }

    var observers: [AnyCancellable] {
        [
            activity,
            buy,
            asset,
            qr,
            send,
            kyc,
            referrals,
            walletConnect,
            onboarding,
            linkCard,
            linkBank
        ]
    }

    public func start() {
        for observer in observers {
            observer.store(in: &bag)
        }
    }

    public func stop() {
        bag = []
    }

    private lazy var activity = app.on(blockchain.app.deep_link.activity)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.showActivity(_:), on: self)

    private lazy var buy = app.on(blockchain.app.deep_link.buy)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.showTransactionBuy(_:), on: self)

    private lazy var send = app.on(blockchain.app.deep_link.send)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.showTransactionSend(_:), on: self)

    private lazy var asset = app.on(blockchain.app.deep_link.asset)
        .sink(to: DeepLinkCoordinator.showAsset, on: self)

    private lazy var qr = app.on(blockchain.app.deep_link.qr)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.qr(_:), on: self)

    private lazy var kyc = app.on(blockchain.app.deep_link.kyc)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.kyc(_:), on: self)

    private lazy var verifyEmail = app.on(blockchain.app.deep_link.kyc.verify.email)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.verifyEmail(_:), on: self)

    private lazy var referrals = app.on(blockchain.app.deep_link.referral)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.handleReferral, on: self)

    private lazy var linkCard = app.on(blockchain.app.deep_link.settings.add.payment.method.card)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.handleLinkCard, on: self)

    private lazy var linkBank = app.on(blockchain.app.deep_link.settings.add.payment.method.bank)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.handleLinkBank, on: self)

    // Debouncing prevents the popup from being dismissed
    private lazy var walletConnect = app.on(blockchain.app.deep_link.walletconnect)
        .debounce(for: .seconds(1), scheduler: DispatchQueue.global(qos: .background))
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.handleWalletConnect, on: self)

    private lazy var onboarding = app.on(blockchain.app.deep_link.onboarding.post.sign.up)
        .receive(on: DispatchQueue.main)
        .flatMap { [weak self] _ -> AnyPublisher<Void, Never> in
            guard let self, let viewController = self.window.topMostViewController else {
                return .empty()
            }
            return self.onboardingRouter.presentPostSignUpOnboarding(from: viewController).mapToVoid()
        }
        .subscribe()

    func kyc(_ event: Session.Event) {
        guard let tier = try? event.context.decode(blockchain.app.deep_link.kyc.tier, as: KYC.Tier.self),
              let topViewController = window.topMostViewController
        else {
            return
        }

        kycRouter
            .presentEmailVerificationAndKYCIfNeeded(from: topViewController, requiredTier: tier)
            .subscribe()
            .store(in: &bag)
    }

    func verifyEmail(_ event: Session.Event) {
        guard let topViewController = window.topMostViewController else { return }
        kycRouter.presentEmailVerificationIfNeeded(from: topViewController)
            .subscribe()
            .store(in: &bag)
    }

    func qr(_ event: Session.Event) {
        let qrCodeScannerView = QRCodeScannerView(
            app: resolve(),
            secureChannelRouter: resolve(),
            walletConnectService: walletConnectService(),
            tabSwapping: resolve()
        )
        window
            .topMostViewController?
            .present(qrCodeScannerView)
    }

    func handleWalletConnect(_ event: Session.Event) {
        if let uri = try? event.context.decode(
            blockchain.app.deep_link.walletconnect.uri,
            as: String.self
        ) {
            let service = walletConnectService()
            Task(priority: .high) { [app] in
                if try await service.pair(uri: uri) {
                    app.state.set(blockchain.app.deep_link.walletconnect.redirect.back.to.dapp, to: true)
                }
            }
        }

        if let _ = try? event.context.decode(
            blockchain.app.deep_link.walletconnect.requestId,
            as: String.self
        ) {
            // in case we detect a requestId, a dApp has a send a request so we'll redicter back to dApp when needed
            app.state.set(blockchain.app.deep_link.walletconnect.redirect.back.to.dapp, to: true)
        }
    }

    func handleReferral(_ event: Session.Event) {
        app.publisher(
            for: blockchain.user.referral.campaign,
            as: Referral.self
        )
        .receive(on: DispatchQueue.main)
        .compactMap(\.value)
        .sink(receiveValue: { referral in
            self.presentReferralCampaign(referral)
        })
        .store(in: &bag)
    }

    func handleLinkCard() {
        guard let viewController = window.topMostViewController else { return }
        paymentMethodLinker.routeToCardLinkingFlow(from: viewController) {
            viewController.dismiss(animated: true)
        }
    }

    func handleLinkBank() {
        Task {
            let currency = try await app.get(blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self)
            await MainActor.run {
                guard let viewController = window.topMostViewController else { return }
                paymentMethodLinker.routeToBankLinkingFlow(for: currency, from: viewController) {
                    viewController.dismiss(animated: true)
                }
            }
        }
    }

    private func presentReferralCampaign(_ referral: Referral) {
        analyticsRecording.record(event: AnalyticsEvents
            .New
            .Deeplinking
            .walletReferralProgramClicked())

        let referralView = ReferFriendView(store: .init(
            initialState: .init(referralInfo: referral),
            reducer: ReferFriendModule.reducer,
            environment: .init(
                mainQueue: .main,
                analyticsRecorder: DIKit.resolve()
            )
        ))

        window
            .topMostViewController?
            .present(referralView)
    }

    func showAsset(_ event: Session.Event) {
        let cryptoCurrency = (
            try? event.context.decode(blockchain.app.deep_link.asset.code) as CryptoCurrency
        ) ?? .bitcoin

        app.post(event: blockchain.ux.asset[cryptoCurrency.code].select)
    }

    func showTransactionBuy(_ event: Session.Event) {
        do {
            let cryptoCurrency = try event.context.decode(blockchain.app.deep_link.buy.crypto.code) as CryptoCurrency
            coincore
                .cryptoAccounts(for: cryptoCurrency)
                .receive(on: DispatchQueue.main)
                .flatMap { [weak self] accounts -> AnyPublisher<TransactionFlowResult, Never> in
                    guard let self else {
                        return .just(.abandoned)
                    }
                    return self
                        .transactionsRouter
                        .presentTransactionFlow(to: .buy(accounts.first))
                }
                .subscribe()
                .store(in: &bag)
        } catch {
            transactionsRouter.presentTransactionFlow(to: .buy(nil))
                .subscribe()
                .store(in: &bag)
        }
    }

    func showTransactionSend(_ event: Session.Event) {

        // If there is no crypto currency, show landing send.
        guard let cryptoCurrency = try? event.context.decode(
            blockchain.app.deep_link.send.crypto.code,
            as: CryptoCurrency.self
        ) else {
            showTransactionSendLanding()
            return
        }

        showTransactionSend(
            cryptoCurrency: cryptoCurrency,
            destination: try? event.context.decode(
                blockchain.app.deep_link.send.destination,
                as: String.self
            )
        )
    }

    private func showTransactionSendLanding() {
        transactionsRouter
            .presentTransactionFlow(to: .send(nil, nil))
            .subscribe()
            .store(in: &bag)
    }

    private func showTransactionSend(
        cryptoCurrency: CryptoCurrency,
        destination: String?
    ) {
        let defaultAccount = coincore.cryptoAccounts(for: cryptoCurrency)
            .map(\.first)
            .eraseError()
        let target = transactionTarget(
            from: destination,
            cryptoCurrency: cryptoCurrency
        )
        .optional()
        .replaceError(with: nil)
        .eraseError()

        defaultAccount
            .zip(target)
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] defaultAccount, target -> AnyPublisher<TransactionFlowResult, Never> in
                guard let self else {
                    return .just(.abandoned)
                }
                return self
                    .transactionsRouter
                    .presentTransactionFlow(to: .send(defaultAccount, target))
            }
            .subscribe()
            .store(in: &bag)
    }

    /// Creates transaction target from given string.
    private func transactionTarget(
        from string: String?,
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<CryptoReceiveAddress, Error> {
        payloadFactory
            .create(fromString: string, asset: cryptoCurrency)
            .eraseError()
            .flatMap { target -> AnyPublisher<CryptoReceiveAddress, Error> in
                switch target {
                case .bitpay(let address):
                    return BitPayInvoiceTarget
                        .make(from: address, asset: cryptoCurrency)
                        .map { $0 as CryptoReceiveAddress }
                        .eraseError()
                        .eraseToAnyPublisher()
                case .address(let cryptoReceiveAddress):
                    return .just(cryptoReceiveAddress)
                }
            }
            .eraseToAnyPublisher()
    }

    func showActivity(_ event: Session.Event) {
        Task {
            let superAppEnabled = try await app.get(blockchain.app.configuration.app.superapp.v1.is.enabled, as: Bool.self)
            if superAppEnabled {
                try await app.set(
                    blockchain.ux.user.activity.all.entry.paragraph.button.primary.tap.then.enter.into,
                    to: blockchain.ux.user.activity.all
                )
                app.post(event: blockchain.ux.user.activity.all.entry.paragraph.button.primary.tap)
            } else {
                app.post(event: blockchain.ux.home.tab[blockchain.ux.user.activity].select)
            }
        }
    }
}
