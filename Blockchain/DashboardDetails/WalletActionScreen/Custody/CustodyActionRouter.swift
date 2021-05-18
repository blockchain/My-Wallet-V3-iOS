//
//  CustodySendRouter.swift
//  Blockchain
//
//  Created by AlexM on 2/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class CustodyActionRouter: CustodyActionRouterAPI {
    
    // MARK: - `Router` Properties
    
    let completionRelay = PublishRelay<Void>()
    
    private var stateService: CustodyActionStateServiceAPI!
    private let backupRouterAPI: BackupRouterAPI
    private let custodyWithdrawalRouter: CustodyWithdrawalRouterAPI
    private let dataProviding: DataProviding

    private let navigationRouter: NavigationRouterAPI

    private var currency: CurrencyType!

    private let tabSwapping: TabSwapping
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let accountProviding: BlockchainAccountProviding
    private let disposeBag = DisposeBag()

    /// Represents a reference of the `WithdrawFlowRouter` object
    /// - note: This is needed in order for the reference to be kept in memory,
    ///         will be release on the dismissal of the flow.
    private var withdrawFiatRouter: WithdrawFlowStarter?
    
    init(navigationRouter: NavigationRouterAPI = NavigationRouter(),
         appSettings: BlockchainSettings.App = resolve(),
         dataProviding: DataProviding = DataProvider.default,
         custodyWithdrawalRouter: CustodyWithdrawalRouterAPI = CustodyWithdrawalRouter(),
         analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
         accountProviding: BlockchainAccountProviding = resolve(),
         backupRouterAPI: BackupRouterAPI,
         tabSwapping: TabSwapping) {
        self.accountProviding = accountProviding
        self.navigationRouter = navigationRouter
        self.analyticsRecorder = analyticsRecorder

        self.custodyWithdrawalRouter = custodyWithdrawalRouter
        self.dataProviding = dataProviding
        self.backupRouterAPI = backupRouterAPI

        self.tabSwapping = tabSwapping
        
        backupRouterAPI
            .completionRelay
            .bindAndCatch(weak: self, onNext: { (self, _) in
                self.stateService.nextRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        custodyWithdrawalRouter
            .completionRelay
            .bindAndCatch(to: completionRelay)
            .disposed(by: disposeBag)
        
        custodyWithdrawalRouter
            .internalSendRelay
            .bindAndCatch(weak: self) { (self, _) in
                self.showSend()
            }
            .disposed(by: disposeBag)
    }
    
    func start(with currency: CurrencyType) {
        // TODO: Would much prefer a different form of injection
        // but we build our `Routers` in the AppCoordinator
        self.currency = currency
        self.stateService = CustodyActionStateService(recoveryStatusProviding: RecoveryPhraseStatusProvider())
        
        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                case .dismiss:
                    self.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }
    
    func next(to state: CustodyActionStateService.State) {
        switch state {
        case .start:
            break
        case .introduction:
            /// The `topMost` screen is the `CustodyActionScreen`
            dismissTopMost { [weak self] in
                guard let self = self else { return }
                self.showIntroductionScreen()
            }
        case .backup,
             .backupAfterIntroduction:
            /// The `topMost` screen is the `CustodyActionScreen`
            dismissTopMost { [weak self] in
                guard let self = self else { return }
                self.backupRouterAPI.start()
            }
        case .send:
            showSendCustody()
        case .activity:
            showActivityScreen()
        case .sell:
            showSell()
        case .swap:
            showSwap()
        case .buy:
            showBuy()
        case .deposit(isKYCApproved: let value):
            switch value {
            case true:
                showPaymentMethods()
            case false:
                showCashIdentityViewController()
            }
        case .withdrawalAfterBackup:
            /// `Backup` has already been dismissed as `Backup`
            /// has ended. `CustodyActionScreen` has been dismissed
            /// prior to `Backup`. There is no `topMost` screen that
            /// needs to be dismissed.
            guard case let .crypto(currency) = currency else { return }
            custodyWithdrawalRouter.start(with: currency)
        case .withdrawal:
            /// The `topMost` screen is the `CustodyActionScreen`
            guard case let .crypto(currency) = currency else { return }
            dismissTopMost { [weak self] in
                guard let self = self else { return }
                self.custodyWithdrawalRouter.start(with: currency)
            }
        case .withdrawalFiat(let isKYCApproved):
            if isKYCApproved {
                guard case let .fiat(currency) = currency else { return }
                showWithdrawFiatScreen(currency: currency)
            } else {
                showCashIdentityViewController()
            }
        case .end:
            dismissTopMost()
        }
    }
    
    private func showSend() {
        dismissTopMost { [unowned self] in
            self.navigationRouter
                .topMostViewControllerProvider
                .topMostViewController?
                .dismiss(animated: true, completion: nil)
            self.accountProviding
                .account(for: currency, accountType: .custodial(.trading))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [unowned self] account in
                    self.tabSwapping.send(from: account)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func showSendCustody() {
        if case let .crypto(cryptoCurrency) = currency {
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbTradingWalletClicked(asset: cryptoCurrency))
        }
        let interactor = WalletActionScreenInteractor(
            accountType: .custodial(.trading),
            currency: currency,
            service: dataProviding.balance[currency.currency]
        )
        let presenter = CustodialActionScreenPresenter(
            using: interactor,
            stateService: stateService
        )
        let controller = WalletActionScreenViewController(using: presenter)
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        navigationRouter.topMostViewControllerProvider.topMostViewController?.present(controller, animated: true, completion: nil)
    }

    private func showActivityScreen() {
        guard case let .crypto(currency) = currency else { return }
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
            self.tabSwapping.switchToActivity(currency: currency)
        }
    }
    
    private func showCashIdentityViewController() {
        guard case .fiat = currency else { return }
        dismissTopMost {
            AppCoordinator.shared.showCashIdentityVerificationScreen()
        }
    }
    
    private func showPaymentMethods() {
        guard case let .fiat(fiatCurrency) = currency else { return }
        dismissTopMost {
            AppCoordinator.shared.showFundTrasferDetails(fiatCurrency: fiatCurrency, isOriginDeposit: true)
        }
    }
    
    private func showSwap() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: {
                AppCoordinator.shared.switchTabToSwap()
            })
        }
    }
    
    private func showBuy() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: {
                guard case let .crypto(currency) = self.currency else { return }
                AppCoordinator.shared.handleBuyCrypto(currency: currency)
            })
        }
    }
    
    private func showSell() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: {
                AppCoordinator.shared.handleSellCrypto()
            })
        }
    }

    private func showIntroductionScreen() {
        let presenter = CustodyInformationScreenPresenter(stateService: stateService)
        let controller = CustodyInformationViewController(presenter: presenter)
        controller.isModalInPresentation = true
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }

    private func showWithdrawFiatScreen(currency: FiatCurrency) {
        let withdrawBuilder = WithdrawBuilder(currency: currency)
        let (router, controller) = withdrawBuilder.build()
        withdrawFiatRouter = router
        let flowDimissed: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.withdrawFiatRouter = nil
        }
        router.startFlow(flowDismissed: flowDimissed)
        dismissTopMost { [weak navigationRouter] in
            navigationRouter?.present(viewController: controller, using: .modalOverTopMost)
        }
    }
    
    func previous() {
        navigationRouter.dismiss()
    }
    
    private func dismissTopMost(completion: (() -> Void)? = nil) {
        navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: completion)
    }
    
    private lazy var sheetPresenter: BottomSheetPresenting = {
        BottomSheetPresenting(ignoresBackroundTouches: false)
    }()
}
