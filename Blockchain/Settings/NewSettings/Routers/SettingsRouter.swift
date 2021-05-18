//
//  SettingsRouter.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit
import DIKit
import KYCKit
import KYCUIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import SafariServices
import ToolKit

final class SettingsRouter: SettingsRouterAPI {
    
    typealias AnalyticsEvent = AnalyticsEvents.Settings
    
    let actionRelay = PublishRelay<SettingsScreenAction>()
    let previousRelay = PublishRelay<Void>()
    
    // MARK: - Routers
    
    private lazy var updateMobileRouter: UpdateMobileRouter = {
        UpdateMobileRouter(navigationRouter: navigationRouter)
    }()
    
    private lazy var backupRouterAPI: BackupRouterAPI = {
        BackupFundsSettingsRouter(navigationRouter: navigationRouter)
    }()
    
    // MARK: - Private
    
    private let guidRepositoryAPI: GuidRepositoryAPI
    private let analyticsRecording: AnalyticsEventRecording
    private let alertPresenter: AlertViewPresenter
    private var cardRouter: CardRouter!
    private let featureConfiguring: FeatureConfiguring

    private let navigationRouter: NavigationRouterAPI
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private unowned let currencyRouting: CurrencyRouting
    private unowned let tabSwapping: TabSwapping
    private unowned let appCoordinator: AppCoordinator

    private let builder: SettingsBuilding

    /// The router for linking a new bank
    private var linkBankFlowRouter: LinkBankFlowStarter?
    
    private let addCardCompletionRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    init(appCoordinator: AppCoordinator = AppCoordinator.shared,
         builder: SettingsBuilding = SettingsBuilder(),
         wallet: Wallet = WalletManager.shared.wallet,
         guidRepositoryAPI: GuidRepositoryAPI = WalletManager.shared.repository,
         navigationRouter: NavigationRouterAPI = NavigationRouter(),
         analyticsRecording: AnalyticsEventRecording = resolve(),
         alertPresenter: AlertViewPresenter = resolve(),
         cardListService: CardListServiceAPI = resolve(),
         paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
         featureConfiguring: FeatureConfiguring = resolve(),
         currencyRouting: CurrencyRouting,
         tabSwapping: TabSwapping) {
        self.appCoordinator = appCoordinator
        self.builder = builder
        self.navigationRouter = navigationRouter
        self.alertPresenter = alertPresenter
        self.analyticsRecording = analyticsRecording
        self.currencyRouting = currencyRouting
        self.tabSwapping = tabSwapping
        self.guidRepositoryAPI = guidRepositoryAPI
        self.paymentMethodTypesService = paymentMethodTypesService
        self.featureConfiguring = featureConfiguring
        
        previousRelay
            .bindAndCatch(weak: self) { (self) in
                self.dismiss()
            }
            .disposed(by: disposeBag)
        
        actionRelay
            .bindAndCatch(weak: self) { (self, action) in
                self.handle(action: action)
            }
            .disposed(by: disposeBag)
        
        addCardCompletionRelay
            .bindAndCatch(weak: self) { (self) in
                cardListService
                    .fetchCards()
                    .subscribe()
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
            
    }
    
    func presentSettings() {
        let interactor = SettingsScreenInteractor(paymentMethodTypesService: paymentMethodTypesService)
        let presenter = SettingsScreenPresenter(interactor: interactor, router: self)
        let controller = SettingsViewController(presenter: presenter)
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }
    
    func dismiss() {
        guard let navController = navigationRouter.navigationControllerAPI else { return }
        if navController.viewControllersCount > 1 {
            navController.popViewController(animated: true)
        } else {
            navController.dismiss(animated: true, completion: nil)
            navigationRouter.navigationControllerAPI = nil
        }
    }
    
    private func handle(action: SettingsScreenAction) {
        switch action {
        case .showURL(let url):
            let controller = SFSafariViewController(url: url)
            navigationRouter.present(viewController: controller)
        case .launchChangePassword:
            let interactor = ChangePasswordScreenInteractor()
            let presenter = ChangePasswordScreenPresenter(previousAPI: self, interactor: interactor)
            let controller = ChangePasswordViewController(presenter: presenter)
            navigationRouter.present(viewController: controller)
        case .showRemoveCardScreen(let data):
            let viewController = builder.removeCardPaymentMethodViewController(cardData: data)
            viewController.transitioningDelegate = sheetPresenter
            viewController.modalPresentationStyle = .custom
            navigationRouter.topMostViewControllerProvider.topMostViewController?.present(viewController, animated: true, completion: nil)
        case .showRemoveBankScreen(let data):
            let viewController = builder.removeBankPaymentMethodViewController(beneficiary: data)
            viewController.transitioningDelegate = sheetPresenter
            viewController.modalPresentationStyle = .custom
            navigationRouter.topMostViewControllerProvider.topMostViewController?.present(viewController, animated: true, completion: nil)
        case .showAddCardScreen:
            let interactor = CardRouterInteractor()
            interactor
                .completionCardData
                .mapToVoid()
                .bindAndCatch(to: addCardCompletionRelay)
                .disposed(by: disposeBag)
            let builder = CardComponentBuilder(
                routingInteractor: interactor,
                paymentMethodTypesService: paymentMethodTypesService
            )
            cardRouter = CardRouter(
                interactor: interactor,
                builder: builder,
                routingType: .modal
            )
            cardRouter.load()
        case .showAddBankScreen(let fiatCurrency):
            if featureConfiguring.configuration(for: .achSettingsEnabled).isEnabled && fiatCurrency == .USD {
                showLinkBankFlow()
                return
            }
            appCoordinator.showFundTrasferDetails(fiatCurrency: fiatCurrency, isOriginDeposit: false)
        case .showAppStore:
            UIApplication.shared.openAppStore()
        case .showBackupScreen:
            backupRouterAPI.start()
        case .showChangePinScreen:
            AuthenticationCoordinator.shared.changePin()
        case .showCurrencySelectionScreen:
            let settingsService: FiatCurrencySettingsServiceAPI = resolve()
            settingsService
                .fiatCurrency
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] currency in
                    self?.showFiatCurrencySelectionScreen(selectedCurrency: currency)
                })
                .disposed(by: disposeBag)
        case .launchWebLogin:
            let presenter = WebLoginScreenPresenter(service: WebLoginQRCodeService())
            let viewController = WebLoginScreenViewController(presenter: presenter)
            viewController.modalPresentationStyle = .overFullScreen
            navigationRouter.present(viewController: viewController)
        case .promptGuidCopy:
            guidRepositoryAPI.guid
                .map(weak: self) { (self, value) -> String in
                    value ?? ""
                }
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] guid in
                    guard let self = self else { return }
                    let alert = UIAlertController(title: LocalizationConstants.AddressAndKeyImport.copyWalletId,
                                                  message: LocalizationConstants.AddressAndKeyImport.copyWarning,
                                                  preferredStyle: .actionSheet)
                    let copyAction = UIAlertAction(
                        title: LocalizationConstants.AddressAndKeyImport.copyCTA,
                        style: .destructive,
                        handler: { [weak self] _ in
                            guard let self = self else { return }
                            self.analyticsRecording.record(event: AnalyticsEvent.settingsWalletIdCopied)
                            UIPasteboard.general.string = guid
                        }
                    )
                    let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    alert.addAction(copyAction)
                    guard let navController = self.navigationRouter.navigationControllerAPI as? UINavigationController else { return }
                    navController.present(alert, animated: true)
                })
                .disposed(by: disposeBag)
            
        case .launchKYC:
            guard let navController = navigationRouter.navigationControllerAPI as? UINavigationController else { return }
            KYCTiersViewController
                .routeToTiers(fromViewController: navController)
                .disposed(by: disposeBag)
        case .launchPIT:
            guard let supportURL = URL(string: Constants.Url.exchangeSupport) else { return }
            let startPITCoordinator = { [weak self] in
                guard let self = self else { return }
                guard let navController = self.navigationRouter.navigationControllerAPI as? UINavigationController else { return }
                ExchangeCoordinator.shared.start(from: navController)
            }
            let launchPIT = AlertAction(
                style: .confirm(LocalizationConstants.Exchange.Launch.launchExchange),
                metadata: .block(startPITCoordinator)
            )
            let contactSupport = AlertAction(
                style: .default(LocalizationConstants.Exchange.Launch.contactSupport),
                metadata: .url(supportURL)
            )
            let model = AlertModel(
                headline: LocalizationConstants.Exchange.title,
                body: nil,
                actions: [launchPIT, contactSupport],
                image: #imageLiteral(resourceName: "exchange-icon-small"),
                dismissable: true,
                style: .sheet
            )
            let alert = AlertView.make(with: model) { [weak self] action in
                guard let self = self else { return }
                guard let metadata = action.metadata else { return }
                switch metadata {
                case .block(let block):
                    block()
                case .url(let support):
                    let controller = SFSafariViewController(url: support)
                    self.navigationRouter.present(viewController: controller)
                case .dismiss,
                     .pop,
                     .payload:
                    break
                }
            }
            alert.show()
        case .showUpdateEmailScreen:
            let interactor = UpdateEmailScreenInteractor()
            let presenter = UpdateEmailScreenPresenter(emailScreenInteractor: interactor)
            let controller = UpdateEmailScreenViewController(presenter: presenter)
            navigationRouter.present(viewController: controller)
        case .showUpdateMobileScreen:
            updateMobileRouter.start()
        case .none:
            break
        }
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
                guard case let .closeFlow(isInteractive) = effect, !isInteractive else {
                    flowDismissed()
                    return
                }
                self?.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: flowDismissed)
            })
            .disposed(by: disposeBag)

    }
    
    private func showFiatCurrencySelectionScreen(selectedCurrency: FiatCurrency) {
        let selectionService = FiatCurrencySelectionService(defaultSelectedData: selectedCurrency)
        let interactor = SelectionScreenInteractor(service: selectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizationConstants.Settings.SelectCurrency.title,
            searchBarPlaceholder: LocalizationConstants.Settings.SelectCurrency.searchBarPlaceholder,
            interactor: interactor
        )
        let viewController = SelectionScreenViewController(presenter: presenter)
        viewController.isModalInPresentation = true
        navigationRouter.present(viewController: viewController)
        
        interactor.selectedIdOnDismissal
            .map { FiatCurrency(code: $0)! }
            .flatMap { currency -> Single<FiatCurrency> in
                let settings: FiatCurrencySettingsServiceAPI = resolve()
                return settings
                    .update(
                        currency: currency,
                        context: .settings
                    )
                    .andThen(Single.just(currency))
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] currency in
                    guard let self = self else { return }
                    /// TODO: Remove this and `fiatCurrencySelected` once `ReceiveBTC` and
                    /// `SendBTC` are replaced with Swift implementations.
                    NotificationCenter.default.post(name: .fiatCurrencySelected, object: nil)
                    self.analyticsRecording.record(
                        event: AnalyticsEvents.Settings.settingsCurrencySelected(currency: currency.code)
                    )
                },
                onError: { [weak self] _ in
                    guard let self = self else { return }
                    self.alertPresenter.standardError(
                        message: LocalizationConstants.GeneralError.loadingData
                    )
                }
            )
            .disposed(by: disposeBag)
    }
        
    private lazy var sheetPresenter: BottomSheetPresenting = {
        BottomSheetPresenting()
    }()
}
