// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import FeatureAuthenticationDomain
import FeatureBackupRecoveryPhraseUI
import FeatureCardPaymentDomain
import FeatureNotificationPreferencesUI
import FeatureReferralDomain
import FeatureReferralUI
import FeatureSettingsDomain
import FeatureUserDeletionData
import FeatureUserDeletionUI
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import SafariServices
import SwiftUI
import ToolKit
import UIKit
import WebKit

public protocol AuthenticationCoordinating: AnyObject {
    func enableBiometrics()
    func changePin()
}

public protocol PaymentMethodsLinkerAPI {
    func routeToBankLinkingFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping () -> Void
    )
    func routeToCardLinkingFlow(from viewController: UIViewController, completion: @escaping () -> Void)
}

public protocol KYCRouterAPI {
    func presentLimitsOverview(from presenter: UIViewController)
}

final class SettingsRouter: SettingsRouterAPI {
    private let app: AppProtocol = resolve()
    typealias AnalyticsEvent = AnalyticsEvents.Settings
    let actionRelay = PublishRelay<SettingsScreenAction>()
    let previousRelay = PublishRelay<Void>()
    let navigationRouter: NavigationRouterAPI

    // MARK: - Routers

    private lazy var updateMobileRouter = UpdateMobileRouter(navigationRouter: navigationRouter)
    private lazy var backupRouterAPI = RecoveryPhraseBackupRouter(
        topViewController: resolve(),
        recoveryStatusProviding: resolve()
    )

    // MARK: - Private

    private let blockchainDomainsRouterAdapter: BlockchainDomainsRouterAdapter
    private let guidRepositoryAPI: FeatureAuthenticationDomain.GuidRepositoryAPI
    private let analyticsRecording: AnalyticsEventRecorderAPI
    private let alertPresenter: AlertViewPresenterAPI
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private unowned let tabSwapping: TabSwapping
    private unowned let authenticationCoordinator: AuthenticationCoordinating
    private unowned let appStoreOpener: AppStoreOpening
    private let passwordRepository: PasswordRepositoryAPI
    private let repository: DataRepositoryAPI
    private let pitConnectionAPI: PITConnectionStatusProviding
    private let builder: SettingsBuilding
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let externalActionsProvider: ExternalActionsProviderAPI
    private let kycRouter: KYCRouterAPI
    private let paymentMethodLinker: PaymentMethodsLinkerAPI
    private let addCardCompletionRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    private let exchangeUrlProvider: () -> String
    private let urlOpener: URLOpener

    private var topViewController: UIViewController {
        let topViewController = navigationRouter.topMostViewControllerProvider.topMostViewController
        guard let viewController = topViewController else {
            fatalError("Failed to present from SettingsRouter, no view controller available for presentation")
        }
        return viewController
    }

    init(
        builder: SettingsBuilding = SettingsBuilder(),
        blockchainDomainsRouterAdapter: BlockchainDomainsRouterAdapter = resolve(),
        guidRepositoryAPI: FeatureAuthenticationDomain.GuidRepositoryAPI = resolve(),
        authenticationCoordinator: AuthenticationCoordinating = resolve(),
        appStoreOpener: AppStoreOpening = resolve(),
        navigationRouter: NavigationRouterAPI = resolve(),
        analyticsRecording: AnalyticsEventRecorderAPI = resolve(),
        alertPresenter: AlertViewPresenterAPI = resolve(),
        kycRouter: KYCRouterAPI = resolve(),
        cardListService: CardListServiceAPI = resolve(),
        paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
        pitConnectionAPI: PITConnectionStatusProviding = resolve(),
        tabSwapping: TabSwapping = resolve(),
        passwordRepository: PasswordRepositoryAPI = resolve(),
        repository: DataRepositoryAPI = resolve(),
        paymentMethodLinker: PaymentMethodsLinkerAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        externalActionsProvider: ExternalActionsProviderAPI = resolve(),
        urlOpener: URLOpener = resolve(),
        exchangeUrlProvider: @escaping () -> String
    ) {
        self.builder = builder
        self.blockchainDomainsRouterAdapter = blockchainDomainsRouterAdapter
        self.authenticationCoordinator = authenticationCoordinator
        self.appStoreOpener = appStoreOpener
        self.navigationRouter = navigationRouter
        self.alertPresenter = alertPresenter
        self.analyticsRecording = analyticsRecording
        self.kycRouter = kycRouter
        self.tabSwapping = tabSwapping
        self.guidRepositoryAPI = guidRepositoryAPI
        self.paymentMethodTypesService = paymentMethodTypesService
        self.pitConnectionAPI = pitConnectionAPI
        self.passwordRepository = passwordRepository
        self.repository = repository
        self.paymentMethodLinker = paymentMethodLinker
        self.analyticsRecorder = analyticsRecorder
        self.externalActionsProvider = externalActionsProvider
        self.exchangeUrlProvider = exchangeUrlProvider

        self.urlOpener = urlOpener

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
                    .asSingle()
                    .subscribe()
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
    }

    func makeViewController() -> BaseScreenViewController {
        let interactor = SettingsScreenInteractor(
            paymentMethodTypesService: paymentMethodTypesService,
            authenticationCoordinator: authenticationCoordinator
        )
        let presenter = SettingsScreenPresenter(app: app, interactor: interactor, router: self)
        return SettingsViewController(presenter: presenter)
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

    // swiftlint:disable:next cyclomatic_complexity
    private func handle(action: SettingsScreenAction) {
        switch action {
        case .showURL(let url):
            navigationRouter
                .navigationControllerAPI?
                .present(SFSafariViewController(url: url), animated: true, completion: nil)
        case .launchChangePassword:
            let interactor = ChangePasswordScreenInteractor(passwordAPI: passwordRepository)
            let presenter = ChangePasswordScreenPresenter(previousAPI: self, interactor: interactor)
            let controller = ChangePasswordViewController(presenter: presenter)
            navigationRouter.present(viewController: controller)
        case .showRemoveCardScreen(let data):
            let viewController = builder.removeCardPaymentMethodViewController(cardData: data)
            viewController.transitioningDelegate = sheetPresenter
            viewController.modalPresentationStyle = .custom
            topViewController.present(viewController, animated: true, completion: nil)
        case .showRemoveBankScreen(let data):
            let viewController = builder.removeBankPaymentMethodViewController(beneficiary: data)
            viewController.transitioningDelegate = sheetPresenter
            viewController.modalPresentationStyle = .custom
            topViewController.present(viewController, animated: true, completion: nil)
        case .showAddCardScreen:
            showCardLinkingFlow()
        case .showAddBankScreen(let fiatCurrency):
            showBankLinkingFlow(currency: fiatCurrency)
        case .showAppStore:
            appStoreOpener.openAppStore()
        case .showBackupScreen:
            backupRouterAPI.presentFlow()
        case .showChangePinScreen:
            authenticationCoordinator.changePin()
        case .showCurrencySelectionScreen:
            let settingsService: FiatCurrencySettingsServiceAPI = resolve()
            settingsService
                .displayCurrency
                .asSingle()
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] currency in
                    self?.showFiatCurrencySelectionScreen(selectedCurrency: currency)
                })
                .disposed(by: disposeBag)
        case .showTradingCurrencySelectionScreen:
            let settingsService: FiatCurrencySettingsServiceAPI = resolve()
            settingsService
                .tradingCurrency
                .asSingle()
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] currency in
                    self?.showFiatTradingCurrencySelectionScreen(selectedCurrency: currency)
                })
                .disposed(by: disposeBag)
        case .promptGuidCopy:
            guidRepositoryAPI.guid.asSingle()
                .map(weak: self) { _, value -> String in
                    value ?? ""
                }
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] guid in
                    guard let self else { return }
                    let alert = UIAlertController(
                        title: LocalizationConstants.AddressAndKeyImport.copyWalletId,
                        message: LocalizationConstants.AddressAndKeyImport.copyWarning,
                        preferredStyle: .actionSheet
                    )
                    let copyAction = UIAlertAction(
                        title: LocalizationConstants.AddressAndKeyImport.copyCTA,
                        style: .destructive,
                        handler: { [weak self] _ in
                            guard let self else { return }
                            analyticsRecording.record(event: AnalyticsEvent.settingsWalletIdCopied)
                            UIPasteboard.general.string = guid
                        }
                    )
                    let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    alert.addAction(copyAction)
                    guard let navController = navigationRouter
                        .navigationControllerAPI as? UINavigationController
                    else {
                        return
                    }
                    navController.present(alert, animated: true)
                })
                .disposed(by: disposeBag)

        case .presentTradeLimits:
            kycRouter.presentLimitsOverview(from: topViewController)

        case .launchPIT:
            guard let exchangeUrl = URL(string: exchangeUrlProvider()) else { return }
            let launchPIT = AlertAction(
                style: .confirm(LocalizationConstants.Exchange.Launch.launchExchange),
                metadata: .url(exchangeUrl)
            )
            let model = AlertModel(
                headline: LocalizationConstants.Exchange.title,
                body: nil,
                actions: [launchPIT],
                image: #imageLiteral(resourceName: "exchange-icon-small"),
                dismissable: true,
                style: .sheet
            )
            let alert = AlertView.make(with: model) { [weak self] action in
                guard let self else { return }
                guard let metadata = action.metadata else { return }
                switch metadata {
                case .block(let block):
                    block()
                case .url(let exchangeUrl):
                    urlOpener.open(exchangeUrl)
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
        case .logout:
            externalActionsProvider.logout()
        case .showContactSupport:
            externalActionsProvider.handleSupport()
        case .showWebLogin:
            externalActionsProvider.handleSecureChannel()
        case .showNotificationsSettings:
            showNotificationsSettingsScreen()
        case .showReferralScreen(let referral):
            showReferralScreen(with: referral)
        case .showUserDeletionScreen:
            showUserDeletionScreen()
        case .showBlockchainDomains:
            showBlockchainDomains()
        case .showThemeSettings:
            showThemeSettings()
        case .none:
            break
        }
    }

    private func showThemeSettings() {
        app.post(
            action: blockchain.ux.settings.theme.settings.entry.then.enter.into,
            value: blockchain.ux.settings.theme.settings,
            context: [:]
        )
    }

    private func showBlockchainDomains() {
        blockchainDomainsRouterAdapter.presentFlow(from: navigationRouter)
    }

    private func showCardLinkingFlow() {
        let presenter = topViewController
        app.state.set(blockchain.ux.error.context.action, to: "SETTINGS_CARD_LINKING")
        paymentMethodLinker.routeToCardLinkingFlow(from: presenter) { [app, addCardCompletionRelay] in
            presenter.dismiss(animated: true) {
                addCardCompletionRelay.accept(())
            }
            app.state.clear(blockchain.ux.error.context.action)
        }
    }

    private func showNotificationsSettingsScreen() {
        analyticsRecording.record(event: AnalyticsEvents.New.Settings.notificationClicked)
        let presenter = topViewController
        let notificationCenterView = FeatureNotificationPreferencesView(store: .init(
            initialState: .init(viewState: .loading),
            reducer: featureNotificationPreferencesMainReducer,
            environment: NotificationPreferencesEnvironment(
                mainQueue: .main,
                notificationPreferencesRepository: DIKit.resolve(),
                analyticsRecorder: DIKit.resolve()
            )
        ))
        presenter.present(notificationCenterView)
    }

    private func showReferralScreen(with referral: Referral) {
        let origin = AnalyticsEvents.New.Settings.ReferralOrigin.profile.rawValue
        analyticsRecording.record(event: AnalyticsEvents
            .New
            .Settings
            .walletReferralProgramClicked(origin: origin))
        let presenter = topViewController
        let referralView = ReferFriendView(store: .init(
            initialState: .init(referralInfo: referral),
            reducer: ReferFriendModule.reducer,
            environment: .init(
                mainQueue: .main,
                analyticsRecorder: DIKit.resolve()
            )
        ))
        presenter.present(referralView)
    }

    private func showUserDeletionScreen() {
        analyticsRecording.record(
            event: AnalyticsEvents.New.Settings.deleteAccountClicked(
                origin: AnalyticsEvents.New.Settings.Origin.settings.rawValue
            )
        )
        let presenter = topViewController
        let logoutAndForgetWallet = { [weak self] in
            presenter.dismiss(animated: true) {
                self?.externalActionsProvider
                    .logoutAndForgetWallet()
            }
        }
        let dismissFlow = {
            presenter.dismiss(animated: true)
        }
        let view = UserDeletionView(store: .init(
            initialState: UserDeletionState(),
            reducer: UserDeletionModule.reducer,
            environment: .init(
                mainQueue: .main,
                userDeletionRepository: resolve(),
                analyticsRecorder: resolve(),
                dismissFlow: dismissFlow,
                logoutAndForgetWallet: logoutAndForgetWallet
            )
        ))
        presenter.present(view)
    }

    private func showBankLinkingFlow(currency: FiatCurrency) {
        analyticsRecorder.record(event: AnalyticsEvents.New.Withdrawal.linkBankClicked(origin: .settings))
        let viewController = topViewController
        paymentMethodLinker.routeToBankLinkingFlow(for: currency, from: viewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
    }

    private func showFiatCurrencySelectionScreen(selectedCurrency: FiatCurrency) {
        let selectionService = FiatCurrencySelectionService(defaultSelectedData: selectedCurrency)
        let interactor = SelectionScreenInteractor(service: selectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizationConstants.Settings.SelectCurrency.title,
            description: LocalizationConstants.Settings.SelectCurrency.description,
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
                        displayCurrency: currency,
                        context: .settings
                    )
                    .asSingle()
                    .asCompletable()
                    .andThen(Single.just(currency))
            }
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] currency in
                    guard let self else { return }
                    // TODO: Remove this and `fiatCurrencySelected` once `ReceiveBTC` and
                    // `SendBTC` are replaced with Swift implementations.
                    NotificationCenter.default.post(name: .fiatCurrencySelected, object: nil)
                    analyticsRecording.record(events: [
                        AnalyticsEvents.Settings.settingsCurrencySelected(currency: currency.code),
                        AnalyticsEvents.New.Settings.settingsCurrencyClicked(currency: currency.code)
                    ])
                },
                onFailure: { [weak self] _ in
                    guard let self else { return }
                    alertPresenter.standardError(
                        message: LocalizationConstants.GeneralError.loadingData
                    )
                }
            )
            .disposed(by: disposeBag)
    }

    private func showFiatTradingCurrencySelectionScreen(selectedCurrency: FiatCurrency) {
        let selectionService = FiatCurrencySelectionService(
            defaultSelectedData: selectedCurrency,
            provider: FiatTradingCurrencySelectionProvider()
        )
        let interactor = SelectionScreenInteractor(service: selectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizationConstants.Settings.SelectCurrency.trading,
            description: LocalizationConstants.Settings.SelectCurrency.tradingDescription,
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
                        tradingCurrency: currency,
                        context: .settings
                    )
                    .asSingle()
                    .asCompletable()
                    .andThen(Single.just(currency))
            }
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] currency in
                    guard let self else { return }
                    analyticsRecording.record(events: [
                        AnalyticsEvents.Settings.settingsTradingCurrencySelected(currency: currency.code),
                        AnalyticsEvents.New.Settings.settingsTradingCurrencyClicked(currency: currency.code)
                    ])
                },
                onFailure: { [weak self] _ in
                    guard let self else { return }
                    alertPresenter.standardError(
                        message: LocalizationConstants.GeneralError.loadingData
                    )
                }
            )
            .disposed(by: disposeBag)
    }

    private lazy var sheetPresenter = BottomSheetPresenting()
}
