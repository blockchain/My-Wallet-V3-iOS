//
//  SimpleBuyRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import SafariServices
import ToolKit

public protocol RouterAPI: class {
    func setup(startImmediately: Bool)
    func start()
    func next(to state: StateService.State)
    func previous(from state: StateService.State)
    func showCryptoSelectionScreen()
    func showFailureAlert()
}

/// This object is used as a router for Simple-Buy flow
public final class Router: RouterAPI {
    
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    
    // MARK: - Private Properties
    
    private let stateService: StateServiceAPI
    private let kycRouter: KYCRouterAPI
    private let supportedPairsInteractor: SupportedPairsInteractorServiceAPI
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let settingsService: FiatCurrencySettingsServiceAPI
    private let cryptoSelectionService: CryptoCurrencySelectionServiceAPI
    private let navigationRouter: NavigationRouterAPI
    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI
    private let alertViewPresenter: AlertViewPresenterAPI
    private let featureConfiguring: FeatureConfiguring
    
    private var cardRouter: CardRouter!
    
    /// A kyc subscription dispose bag
    private var kycDisposeBag = DisposeBag()
        
    /// A general dispose bag
    private let disposeBag = DisposeBag()
    
    private let builder: Buildable

    /// The router for payment methods flow
    private var achFlowRouter: ACHFlowStarter?
    /// The router for linking a new bank
    private var linkBankFlowRouter: LinkBankFlowStarter?
    
    // MARK: - Setup
    
    public init(navigationRouter: NavigationRouterAPI,
                paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
                settingsService: CompleteSettingsServiceAPI = resolve(),
                supportedPairsInteractor: SupportedPairsInteractorServiceAPI = resolve(),
                internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve(),
                alertViewPresenter: AlertViewPresenterAPI = resolve(),
                featureConfiguring: FeatureConfiguring = resolve(),
                builder: Buildable,
                kycRouter: KYCRouterAPI,
                currency: CryptoCurrency) {
        self.navigationRouter = navigationRouter
        self.supportedPairsInteractor = supportedPairsInteractor
        self.settingsService = settingsService
        self.alertViewPresenter = alertViewPresenter
        self.featureConfiguring = featureConfiguring
        self.stateService = builder.stateService
        self.kycRouter = kycRouter
        self.builder = builder
        self.internalFeatureFlagService = internalFeatureFlagService
        
        let cryptoSelectionService = CryptoCurrencySelectionService(
            service: supportedPairsInteractor,
            defaultSelectedData: currency
        )
        self.paymentMethodTypesService = paymentMethodTypesService
        self.cryptoSelectionService = cryptoSelectionService
    }
    
    public func showCryptoSelectionScreen() {
        typealias LocalizedString = LocalizationConstants.SimpleBuy.CryptoSelectionScreen
        let interactor = SelectionScreenInteractor(service: cryptoSelectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizedString.title,
            searchBarPlaceholder: LocalizedString.searchBarPlaceholder,
            interactor: interactor
        )
        let viewController = SelectionScreenViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationRouter.navigationControllerAPI?.present(navigationController, animated: true, completion: nil)
    }

    public func showFailureAlert() {
        alertViewPresenter.error(in: navigationRouter.topMostViewControllerProvider.topMostViewController) { [weak self] in
            self?.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
        }
    }
            
    /// Should be called once
    public func setup(startImmediately: Bool) {
        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous(let state):
                    self.previous(from: state)
                case .next(let state):
                    self.next(to: state)
                case .dismiss:
                    self.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        if startImmediately {
            stateService.nextRelay.accept(())
        }
    }
    
    /// Should be called once
    public func start() {
        setup(startImmediately: true)
    }
    
    public func next(to state: StateService.State) {
        switch state {
        case .intro:
            showIntroScreen()
        case .changeFiat:
            settingsService
                .fiatCurrency
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] currency in
                    self?.showFiatCurrencyChangeScreen(selectedCurrency: currency)
                })
                .disposed(by: disposeBag)
        case .selectFiat:
            settingsService
                .fiatCurrency
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] currency in
                    self?.showFiatCurrencySelectionScreen(selectedCurrency: currency)
                })
                .disposed(by: disposeBag)
        case .unsupportedFiat(let currency):
            showInelligibleCurrency(with: currency)
        case .buy:
            showBuyCryptoScreen()
        case .checkout(let data):
            showCheckoutScreen(with: data)
        case .pendingOrderDetails(let data):
            showCheckoutScreen(with: data)
        case .authorizeCard(let data):
            showCardAuthorization(with: data)
        case .pendingOrderCompleted(orderDetails: let orderDetails):
            showPendingOrderCompletionScreen(for: orderDetails)
        case .paymentMethods:
            showPaymentMethodsScreen()
        case .bankTransferDetails(let data):
            showBankTransferDetailScreen(with: data)
        case .fundsTransferDetails(let currency, isOriginPaymentMethods: let isOriginPaymentMethods, let isOriginDeposit):
            guard let fiatCurrency = currency.fiatCurrency else { return }
            showFundsTransferDetailsScreen(with: fiatCurrency, shouldDismissModal: isOriginPaymentMethods, isOriginDeposit: isOriginDeposit)
        case .transferCancellation(let data):
            showTransferCancellation(with: data)
        case .kyc:
            showKYC(afterDismissal: true)
        case .kycBeforeCheckout:
            showKYC(afterDismissal: false)
        case .showURL(let url):
            showSafariViewController(with: url)
        case .pendingKycApproval, .ineligible:
            /// Show pending KYC approval for `ineligible` state as well, since the expected poll result would be
            /// ineligible anyway
            showPendingKycApprovalScreen()
        case .linkBank:
            showLinkBankFlow()
        case .addCard(let data):
            startCardAdditionFlow(with: data)
        case .inactive:
            navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
        }
    }
    
    public func previous(from state: StateService.State) {
        switch state {
        // Some independent flows which dismiss themselves.
        // Therefore, do nothing.
        case .kyc, .selectFiat, .changeFiat, .unsupportedFiat, .addCard, .linkBank:
            break
        case .paymentMethods, .bankTransferDetails, .fundsTransferDetails:
            navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
        default:
            navigationRouter.dismiss()
        }
    }
    
    private func startCardAdditionFlow(with checkoutData: CheckoutData) {
        let interactor = stateService.cardRoutingInteractor(
            with: checkoutData
        )
        let builder = CardComponentBuilder(
            routingInteractor: interactor,
            paymentMethodTypesService: paymentMethodTypesService
        )
        cardRouter = CardRouter(
            interactor: interactor,
            builder: builder,
            routingType: .modal
        )
        
        /// TODO: This is a temporary patch of the card router intialization, and should not be called directly.
        /// The reason that it is called directly now is that the `Self` is not a RIBs based. Once BuySell's router
        /// moves into RIBs we will delete that like
        cardRouter.load()
    }
    
    private func showSafariViewController(with url: URL) {
        navigationRouter.dismiss { [weak self] in
            guard let self = self else { return }
            let controller = SFSafariViewController(url: url)
            controller.modalPresentationStyle = .overFullScreen
            guard let top = self.navigationRouter.topMostViewControllerProvider.topMostViewController else { return }
            top.present(controller, animated: true, completion: nil)
        }
    }
    
    private func showFiatCurrencyChangeScreen(selectedCurrency: FiatCurrency) {
        let selectionService = FiatCurrencySelectionService(
            defaultSelectedData: selectedCurrency,
            provider: FiatCurrencySelectionProvider()
        )
        let interactor = SelectionScreenInteractor(service: selectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizationConstants.localCurrency,
            description: LocalizationConstants.localCurrencyDescription,
            searchBarPlaceholder: LocalizationConstants.Settings.SelectCurrency.searchBarPlaceholder,
            interactor: interactor
        )
        let viewController = SelectionScreenViewController(presenter: presenter)
        viewController.isModalInPresentation = true

        do {
            let analytics: AnalyticsEventRecorderAPI = resolve()
            analytics.record(event: AnalyticsEvent.sbCurrencySelectScreen)
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationRouter.navigationControllerAPI?.present(navigationController, animated: true, completion: nil)
        
        interactor.selectedIdOnDismissal
            .map { FiatCurrency(code: $0)! }
            .flatMap(weak: self, { (self, currency) -> Single<FiatCurrency> in
                // TICKET: IOS-3144
                self.settingsService
                    .update(
                        currency: currency,
                        context: .simpleBuy
                    )
                    .andThen(Single.just(currency))
            })
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] currency in
                    guard let self = self else { return }
                    /// TODO: Remove this and `fiatCurrencySelected` once `ReceiveBTC` and
                    /// `SendBTC` are replaced with Swift implementations.
                    NotificationCenter.default.post(name: .fiatCurrencySelected, object: nil)
                    self.analytics.record(event: AnalyticsEvent.sbCurrencySelected(currencyCode: currency.code))
                    
                    self.stateService.previousRelay.accept(())
                })
            .disposed(by: disposeBag)
    }
    
    private func showFiatCurrencySelectionScreen(selectedCurrency: FiatCurrency) {
        let selectionService = FiatCurrencySelectionService(defaultSelectedData: selectedCurrency)
        let interactor = SelectionScreenInteractor(service: selectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizationConstants.localCurrency,
            description: LocalizationConstants.localCurrencyDescription,
            shouldPreselect: false,
            searchBarPlaceholder: LocalizationConstants.Settings.SelectCurrency.searchBarPlaceholder,
            interactor: interactor
        )
        let viewController = SelectionScreenViewController(presenter: presenter)
        viewController.isModalInPresentation = true

        if navigationRouter.navigationControllerAPI == nil {
            navigationRouter.present(viewController: viewController)
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationRouter.navigationControllerAPI?.present(navigationController, animated: true, completion: nil)
        }
        
        interactor.dismiss
            .bind { [weak self] in
                self?.stateService.previousRelay.accept(())
            }
            .disposed(by: disposeBag)
        
        interactor.selectedIdOnDismissal
            .map { FiatCurrency(code: $0)! }
            .flatMap(weak: self, { (self, currency) -> Single<(FiatCurrency, Bool)> in

                let isCurrencySupported = self.supportedPairsInteractor
                    .fetch()
                    .map { !$0.pairs.isEmpty }
                    .take(1)
                    .asSingle()

                // TICKET: IOS-3144
                return self.settingsService
                    .update(
                        currency: currency,
                        context: .simpleBuy
                    )
                    .andThen(Single.zip(
                        Single.just(currency),
                        isCurrencySupported
                    ))
            })
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] value in
                    guard let self = self else { return }
                    /// TODO: Remove this and `fiatCurrencySelected` once `ReceiveBTC` and
                    /// `SendBTC` are replaced with Swift implementations.
                    NotificationCenter.default.post(name: .fiatCurrencySelected, object: nil)
                    self.analytics.record(event: AnalyticsEvent.sbCurrencySelected(currencyCode: value.0.code))
                    
                    let isFiatCurrencySupported = value.1
                    let currency = value.0
                    
                    self.navigationRouter.dismiss {
                        self.stateService.previousRelay.accept(())
                        if !isFiatCurrencySupported {
                            self.stateService.ineligible(with: currency)
                        } else {
                            self.stateService.currencySelected()
                        }
                    }
                })
            .disposed(by: disposeBag)
    }
    
    private func showPaymentMethodsScreen() {
        guard featureConfiguring.configuration(for: .achBuyFlowEnabled).isEnabled else {
            showOldPaymentMethodsScreen()
            return
        }
        showACHPaymentMethodsScreen()
    }

    private func showACHPaymentMethodsScreen() {
        let builder = ACHFlowRootBuilder(stateService: stateService)
        // we need to pass the the navigation controller so we can present and dismiss from within the flow.
        let router = builder.build(presentingController: navigationRouter.navigationControllerAPI)
        self.achFlowRouter = router
        let flowDimissed: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.achFlowRouter = nil
        }
        router.startFlow(flowDismissed: flowDimissed)
    }

    private func showOldPaymentMethodsScreen() {
        let interactor = PaymentMethodsScreenInteractor(paymentMethodTypesService: paymentMethodTypesService)
        let presenter = PaymentMethodsScreenPresenter(
            interactor: interactor,
            stateService: stateService
        )
        let viewController = PaymentMethodsScreenViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationRouter.navigationControllerAPI?.present(navigationController, animated: true, completion: nil)
    }

    private func showLinkBankFlow() {
        let builder = LinkBankFlowRootBuilder()
        // we need to pass the the navigation controller so we can present and dismiss from within the flow.
        let router = builder.build(presentingController: navigationRouter.navigationControllerAPI)
        self.linkBankFlowRouter = router
        let flowDismissed: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.linkBankFlowRouter = nil
        }
        router.startFlow()
            .takeUntil(.inclusive, predicate: { $0.isCloseEffect })
            .skipWhile { $0.shouldSkipEffect }
            .subscribe(onNext: { [weak self] effect in
                guard let self = self else { return }
                guard case let .closeFlow(isInteractive) = effect, !isInteractive else {
                    self.stateService.previousRelay.accept(())
                    flowDismissed()
                    return
                }
                self.stateService.previousRelay.accept(())
                self.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: flowDismissed)
            })
            .disposed(by: disposeBag)
    }
    
    private func showInelligibleCurrency(with currency: FiatCurrency) {
        let presenter = IneligibleCurrencyScreenPresenter(
            currency: currency,
            stateService: stateService
        )
        let controller = IneligibleCurrencyViewController(presenter: presenter)
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        analytics.record(event: AnalyticsEvent.sbCurrencyUnsupported)
        navigationRouter.topMostViewControllerProvider.topMostViewController?.present(controller, animated: true, completion: nil)
    }
    
    /// Shows the checkout details screen
    private func showBankTransferDetailScreen(with data: CheckoutData) {
        let interactor = BankTransferDetailScreenInteractor(
            checkoutData: data
        )
        
        let webViewRouter = WebViewRouter(
            topMostViewControllerProvider: navigationRouter.topMostViewControllerProvider
        )
        
        let presenter = BankTransferDetailScreenPresenter(
            webViewRouter: webViewRouter,
            interactor: interactor,
            stateService: stateService
        )
        let viewController = DetailsScreenViewController(presenter: presenter)
        navigationRouter.present(viewController: viewController)
    }
    
    private func showFundsTransferDetailsScreen(with fiatCurrency: FiatCurrency, shouldDismissModal: Bool, isOriginDeposit: Bool) {
        let viewController = builder.fundsTransferDetailsViewController(for: fiatCurrency, isOriginDeposit: isOriginDeposit)
        if shouldDismissModal {
            navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true) { [weak self] in
                self?.navigationRouter.navigationControllerAPI?.present(viewController, animated: true, completion: nil)
            }
        } else {
            navigationRouter.present(viewController: viewController, using: .modalOverTopMost)
        }
    }
    
    /// Shows the cancellation modal
    private func showTransferCancellation(with data: CheckoutData) {
        let interactor = TransferCancellationInteractor(
            checkoutData: data
        )
        
        let presenter = TransferCancellationScreenPresenter(
            routingInteractor: BuyTransferCancellationRoutingInteractor(
                stateService: stateService
            ),
            currency: data.outputCurrency,
            interactor: interactor
        )
        let viewController = TransferCancellationViewController(presenter: presenter)
        viewController.transitioningDelegate = sheetPresenter
        viewController.modalPresentationStyle = .custom
        navigationRouter.topMostViewControllerProvider.topMostViewController?.present(viewController, animated: true, completion: nil)
    }
    
    /// Shows the checkout screen
    private func showCheckoutScreen(with data: CheckoutData) {
        let orderInteractor: OrderCheckoutInteracting
        switch data.order.paymentMethod {
        case .card:
            orderInteractor = BuyOrderCardCheckoutInteractor(
                cardInteractor: CardOrderCheckoutInteractor()
            )
        case .funds, .bankAccount:
            orderInteractor = BuyOrderFundsCheckoutInteractor(
                fundsAndBankInteractor: FundsAndBankOrderCheckoutInteractor()
            )
        case .bankTransfer:
            orderInteractor = BuyOrderFundsCheckoutInteractor(
                fundsAndBankInteractor: FundsAndBankOrderCheckoutInteractor()
            )
        }

        let interactor = CheckoutScreenInteractor(
            orderCheckoutInterator: orderInteractor,
            checkoutData: data
        )
        let presenter = CheckoutScreenPresenter(
            checkoutRouting: BuyCheckoutRoutingInteractor(
                stateService: stateService
            ),
            contentReducer: BuyCheckoutScreenContentReducer(data: data),
            interactor: interactor
        )
        let viewController = DetailsScreenViewController(presenter: presenter)
        navigationRouter.present(viewController: viewController)
    }
    
    private func showPendingOrderCompletionScreen(for orderDetails: OrderDetails) {
        let interactor = PendingOrderStateScreenInteractor(
            orderDetails: orderDetails
        )
        let presenter = PendingOrderStateScreenPresenter(
            routingInteractor: BuyPendingOrderRoutingInteractor(stateService: stateService),
            interactor: interactor
        )
        let viewController = PendingStateViewController(
            presenter: presenter
        )
        navigationRouter.present(viewController: viewController)
    }
    
    private func showCardAuthorization(with data: OrderDetails) {
        
        let interactor = CardAuthorizationScreenInteractor(
            routingInteractor: stateService
        )
        
        let presenter = CardAuthorizationScreenPresenter(
            interactor: interactor,
            data: data.authorizationData!
        )
        let viewController = CardAuthorizationScreenViewController(
            presenter: presenter
        )
        navigationRouter.present(viewController: viewController)
    }

    /// Show the pending kyc screen
    private func showPendingKycApprovalScreen() {
        let interactor = KYCPendingInteractor()
        let presenter = KYCPendingPresenter(
            stateService: stateService,
            interactor: interactor
        )
        let viewController = PendingStateViewController(presenter: presenter)
        navigationRouter.present(viewController: viewController, using: .navigationFromCurrent)
    }
    
    private func showKYC(afterDismissal: Bool) {
        guard let kycRootViewController = navigationRouter.navigationControllerAPI as? UIViewController else {
            return
        }
        
        kycDisposeBag = DisposeBag()
        let stopped = kycRouter.kycStopped
            .take(1)
            .observeOn(MainScheduler.instance)
            .share()
        
        stopped
            .filter { $0 == .tier2 }
            .mapToVoid()
            .bindAndCatch(to: stateService.nextRelay)
            .disposed(by: kycDisposeBag)
        
        stopped
            .filter { $0 != .tier2 }
            .mapToVoid()
            .bindAndCatch(to: stateService.previousRelay)
            .disposed(by: kycDisposeBag)
        
        if afterDismissal {
            navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true) { [weak self] in
                self?.kycRouter.start(from: kycRootViewController, tier: .tier2, parentFlow: .simpleBuy)
            }
        } else {
            kycRouter.start(from: kycRootViewController, tier: .tier2, parentFlow: .simpleBuy)
        }
    }
    
    /// Shows buy-crypto screen using a specified presentation type
    private func showBuyCryptoScreen() {
        let interactor = BuyCryptoScreenInteractor(
            paymentMethodTypesService: paymentMethodTypesService,
            cryptoCurrencySelectionService: cryptoSelectionService
        )

        let presenter = BuyCryptoScreenPresenter(
            router: self,
            stateService: stateService,
            interactor: interactor
        )
        let viewController = EnterAmountScreenViewController(presenter: presenter)
        
        navigationRouter.present(viewController: viewController)
    }

    /// Shows intro screen using a specified presentation type
    private func showIntroScreen() {
        let presenter = BuyIntroScreenPresenter(
            stateService: stateService
        )
        let viewController = BuyIntroScreenViewController(presenter: presenter)
        navigationRouter.present(viewController: viewController)
    }
    
    private lazy var sheetPresenter: BottomSheetPresenting = {
        BottomSheetPresenting(ignoresBackroundTouches: true)
    }()
    
    private lazy var analytics: AnalyticsEventRecorderAPI = { () -> AnalyticsEventRecorderAPI in
        DIKit.resolve()
    }()
}
