// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureAuthenticationDomain
import FeatureCardsDomain
import FeatureSettingsDomain
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

public protocol ExchangeCoordinating: AnyObject {
    func start(from viewController: UIViewController)
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

    typealias AnalyticsEvent = AnalyticsEvents.Settings

    let actionRelay = PublishRelay<SettingsScreenAction>()
    let previousRelay = PublishRelay<Void>()
    let navigationRouter: NavigationRouterAPI

    // MARK: - Routers

    private lazy var updateMobileRouter: UpdateMobileRouter = UpdateMobileRouter(navigationRouter: navigationRouter)

    private lazy var backupRouterAPI: BackupFundsRouterAPI = BackupFundsRouter(entry: .settings, navigationRouter: navigationRouter)

    // MARK: - Private

    private let guidRepositoryAPI: FeatureAuthenticationDomain.GuidRepositoryAPI
    private let analyticsRecording: AnalyticsEventRecorderAPI
    private let alertPresenter: AlertViewPresenter

    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private unowned let tabSwapping: TabSwapping
    private unowned let authenticationCoordinator: AuthenticationCoordinating
    private unowned let exchangeCoordinator: ExchangeCoordinating
    private unowned let appStoreOpener: AppStoreOpening
    private let passwordRepository: PasswordRepositoryAPI
    private let wallet: WalletRecoveryVerifing
    private let repository: DataRepositoryAPI
    private let pitConnectionAPI: PITConnectionStatusProviding
    private let builder: SettingsBuilding
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let externalActionsProvider: ExternalActionsProviderAPI

    private let kycRouter: KYCRouterAPI
    private let paymentMethodLinker: PaymentMethodsLinkerAPI

    private let addCardCompletionRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()

    private var topViewController: UIViewController {
        let topViewController = navigationRouter.topMostViewControllerProvider.topMostViewController
        guard let viewController = topViewController else {
            fatalError("Failed to present open banking flow, no view controller available for presentation")
        }
        return viewController
    }

    init(
        builder: SettingsBuilding = SettingsBuilder(),
        wallet: WalletRecoveryVerifing = resolve(),
        guidRepositoryAPI: FeatureAuthenticationDomain.GuidRepositoryAPI = resolve(),
        authenticationCoordinator: AuthenticationCoordinating = resolve(),
        exchangeCoordinator: ExchangeCoordinating = resolve(),
        appStoreOpener: AppStoreOpening = resolve(),
        navigationRouter: NavigationRouterAPI = resolve(),
        analyticsRecording: AnalyticsEventRecorderAPI = resolve(),
        alertPresenter: AlertViewPresenter = resolve(),
        kycRouter: KYCRouterAPI = resolve(),
        cardListService: CardListServiceAPI = resolve(),
        paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
        pitConnectionAPI: PITConnectionStatusProviding = resolve(),
        tabSwapping: TabSwapping = resolve(),
        passwordRepository: PasswordRepositoryAPI = resolve(),
        repository: DataRepositoryAPI = resolve(),
        paymentMethodLinker: PaymentMethodsLinkerAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        externalActionsProvider: ExternalActionsProviderAPI = resolve()
    ) {
        self.wallet = wallet
        self.builder = builder
        self.authenticationCoordinator = authenticationCoordinator
        self.exchangeCoordinator = exchangeCoordinator
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
        self.featureFlagsService = featureFlagsService
        self.externalActionsProvider = externalActionsProvider

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

    func makeViewController() -> SettingsViewController {
        let interactor = SettingsScreenInteractor(
            pitConnectionAPI: pitConnectionAPI,
            wallet: wallet,
            paymentMethodTypesService: paymentMethodTypesService,
            authenticationCoordinator: authenticationCoordinator
        )
        let presenter = SettingsScreenPresenter(interactor: interactor, router: self)
        return SettingsViewController(presenter: presenter)
    }

    func presentSettings() {
        navigationRouter.present(viewController: makeViewController(), using: .modalOverTopMost)
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

    // swiftlint:disable:next cyclomatic_complexity function_body_length
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
            backupRouterAPI.start()
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
        case .launchWebLogin:
            let presenter = WebLoginScreenPresenter(service: WebLoginQRCodeService())
            let viewController = WebLoginScreenViewController(presenter: presenter)
            viewController.modalPresentationStyle = .overFullScreen
            navigationRouter.present(viewController: viewController)
        case .promptGuidCopy:
            guidRepositoryAPI.guid.asSingle()
                .map(weak: self) { _, value -> String in
                    value ?? ""
                }
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] guid in
                    guard let self = self else { return }
                    let alert = UIAlertController(
                        title: LocalizationConstants.AddressAndKeyImport.copyWalletId,
                        message: LocalizationConstants.AddressAndKeyImport.copyWarning,
                        preferredStyle: .actionSheet
                    )
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
                    guard let navController = self.navigationRouter
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
            guard let supportURL = URL(string: Constants.Url.exchangeSupport) else { return }
            let startPITCoordinator = { [weak self] in
                guard let self = self else { return }
                guard let navController = self.navigationRouter
                    .navigationControllerAPI as? UINavigationController else { return }
                self.exchangeCoordinator.start(from: navController)
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
        case .logout:
            externalActionsProvider.logout()
        case .showAccountsAndAddresses:
            externalActionsProvider.handleAccountsAndAddresses()
        case .showAirdrops:
            externalActionsProvider.handleAirdrops()
        case .showContactSupport:
            externalActionsProvider.handleSupport()
        case .showWebLogin:
            externalActionsProvider.handleSecureChannel()
        case .showCardIssuance:
            showCardIssuanceFlow()
        case .none:
            break
        }
    }

    private func showCardIssuanceFlow() {}

    private func showCardLinkingFlow() {
        let presenter = topViewController
        paymentMethodLinker.routeToCardLinkingFlow(from: presenter) { [addCardCompletionRelay] in
            presenter.dismiss(animated: true) {
                addCardCompletionRelay.accept(())
            }
        }
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
                    guard let self = self else { return }
                    // TODO: Remove this and `fiatCurrencySelected` once `ReceiveBTC` and
                    // `SendBTC` are replaced with Swift implementations.
                    NotificationCenter.default.post(name: .fiatCurrencySelected, object: nil)
                    self.analyticsRecording.record(events: [
                        AnalyticsEvents.Settings.settingsCurrencySelected(currency: currency.code),
                        AnalyticsEvents.New.Settings.settingsCurrencyClicked(currency: currency.code)
                    ])
                },
                onFailure: { [weak self] _ in
                    guard let self = self else { return }
                    self.alertPresenter.standardError(
                        message: LocalizationConstants.GeneralError.loadingData
                    )
                }
            )
            .disposed(by: disposeBag)
    }

    private lazy var sheetPresenter: BottomSheetPresenting = BottomSheetPresenting()
}
