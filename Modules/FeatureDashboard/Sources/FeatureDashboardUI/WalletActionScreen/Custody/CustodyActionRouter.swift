// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureTransactionUI
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import RxToolKit
import ToolKit

public protocol BackupRouterAPI {
    var completionRelay: PublishRelay<Void> { get }

    func start()
}

public protocol WalletOperationsRouting {
    func handleSwapCrypto(account: CryptoAccount?)
    func handleSellCrypto(account: CryptoAccount?)
    func handleBuyCrypto(account: CryptoAccount?)
    func handleBuyCrypto(currency: CryptoCurrency)
    func showCashIdentityVerificationScreen()
    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool)
    func switchTabToSwap()
}

public final class CustodyActionRouter: CustodyActionRouterAPI {

    // MARK: - `Router` Properties

    public let completionRelay = PublishRelay<Void>()
    public let analyticsService: SimpleBuyAnalayticsServicing
    public let walletOperationsRouter: WalletOperationsRouting

    private var stateService: CustodyActionStateServiceAPI!
    private let backupRouterAPI: BackupRouterAPI
    private let custodyWithdrawalRouter: CustodyWithdrawalRouterAPI
    private var depositRouter: DepositRootRouting!

    private let navigationRouter: NavigationRouterAPI

    private var account: BlockchainAccount!
    private var currency: CurrencyType! {
        account?.currencyType
    }

    private let tabSwapping: TabSwapping
    private let accountProviding: BlockchainAccountProviding
    private let analyticsRecoder: AnalyticsEventRecorderAPI
    private let featureFetching: RxFeatureFetching
    private var disposeBag = DisposeBag()

    public convenience init(backupRouterAPI: BackupRouterAPI, tabSwapping: TabSwapping) {
        self.init(
            backupRouterAPI: backupRouterAPI,
            tabSwapping: tabSwapping,
            custodyWithdrawalRouter: CustodyWithdrawalRouter()
        )
    }

    init(
        backupRouterAPI: BackupRouterAPI,
        tabSwapping: TabSwapping,
        custodyWithdrawalRouter: CustodyWithdrawalRouterAPI,
        navigationRouter: NavigationRouterAPI = resolve(),
        accountProviding: BlockchainAccountProviding = resolve(),
        analyticsService: SimpleBuyAnalayticsServicing = resolve(),
        walletOperationsRouter: WalletOperationsRouting = resolve(),
        featureFetching: RxFeatureFetching = resolve(),
        analyticsRecoder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.featureFetching = featureFetching
        self.accountProviding = accountProviding
        self.navigationRouter = navigationRouter

        self.custodyWithdrawalRouter = custodyWithdrawalRouter
        self.walletOperationsRouter = walletOperationsRouter
        self.backupRouterAPI = backupRouterAPI

        self.analyticsService = analyticsService

        self.tabSwapping = tabSwapping
        self.analyticsRecoder = analyticsRecoder

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

    public func start(with account: BlockchainAccount) {
        // TODO: Would much prefer a different form of injection
        // but we build our `Routers` in the AppCoordinator
        self.account = account
        stateService = CustodyActionStateService(recoveryStatusProviding: resolve())

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

    public func next(to state: CustodyActionState) {
        switch state {
        case .start:
            showWalletActionSheet()
        case .introduction:
            /// The `topMost` screen is the `CustodyActionScreen`
            dismiss { [weak self] in
                guard let self = self else { return }
                self.showIntroductionScreen()
            }
        case .backup,
             .backupAfterIntroduction:
            /// The `topMost` screen is the `CustodyActionScreen`
            dismiss { [weak self] in
                guard let self = self else { return }
                self.backupRouterAPI.start()
            }
        case .send:
            showSend()
        case .receive:
            showReceive()
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
                showDepositFlow()
            case false:
                showCashIdentityViewController()
            }
        case .withdrawalAfterBackup:
            /// `Backup` has already been dismissed as `Backup`
            /// has ended. `CustodyActionScreen` has been dismissed
            /// prior to `Backup`. There is no `topMost` screen that
            /// needs to be dismissed.
            guard case .crypto(let currency) = currency else { return }
            custodyWithdrawalRouter.start(with: currency)
        case .withdrawal:
            /// The `topMost` screen is the `CustodyActionScreen`
            guard case .crypto(let currency) = currency else { return }
            dismiss { [weak self] in
                guard let self = self else { return }
                self.custodyWithdrawalRouter.start(with: currency)
            }
        case .withdrawalFiat(let isKYCApproved):
            analyticsRecoder.record(event: AnalyticsEvents.New.Withdrawal.withdrawalClicked(origin: .currencyPage))
            if isKYCApproved {
                guard case .fiat(let currency) = currency else { return }
                showWithdrawFiatScreen(currency: currency)
            } else {
                showCashIdentityViewController()
            }
        case .end:
            dismiss()
        }
    }

    private func showSend() {
        dismiss { [weak self] in
            guard let self = self else {
                return
            }
            self.tabSwapping.send(from: self.account)
        }
    }

    private func showReceive() {
        dismiss { [weak self] in
            guard let self = self else {
                return
            }
            if let account = self.account {
                self.tabSwapping.receive(into: account)
            } else {
                self.tabSwapping.switchTabToReceive()
            }
        }
    }

    private func showWalletActionSheet() {
        if case .crypto(let cryptoCurrency) = account.currencyType {
            analyticsService.recordTradingWalletClicked(for: cryptoCurrency)
        }
        let interactor = WalletActionScreenInteractor(account: account)
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
        dismiss { [weak self] in
            self?.tabSwapping.switchToActivity()
        }
    }

    private func showCashIdentityViewController() {
        guard case .fiat = currency else { return }
        dismiss { [weak self] in
            self?.walletOperationsRouter.showCashIdentityVerificationScreen()
        }
    }

    private func showDepositFlow() {
        dismiss { [weak self] in
            guard let self = self else { return }
            self.accountProviding
                .accounts(for: self.currency)
                .compactMap(\.first)
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] account in
                    self?.tabSwapping.deposit(into: account)
                })
                .disposed(by: self.disposeBag)
        }
    }

    private func showFundTransferDetails(_ currency: FiatCurrency) {
        dismiss { [weak self] in
            self?.walletOperationsRouter.showFundTrasferDetails(
                fiatCurrency: currency,
                isOriginDeposit: true
            )
        }
    }

    private func showSwap() {
        dismiss { [walletOperationsRouter, account] in
            walletOperationsRouter.handleSwapCrypto(account: account as? CryptoAccount)
        }
    }

    private func showBuy() {
        dismiss { [walletOperationsRouter, account] in
            walletOperationsRouter.handleBuyCrypto(account: account as? CryptoAccount)
        }
    }

    private func showSell() {
        dismiss { [walletOperationsRouter, account] in
            walletOperationsRouter.handleSellCrypto(account: account as? CryptoAccount)
        }
    }

    private func showIntroductionScreen() {
        let presenter = CustodyInformationScreenPresenter(stateService: stateService)
        let controller = CustodyInformationViewController(presenter: presenter)
        controller.isModalInPresentation = true
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }

    private func showWithdrawFiatScreen(currency: FiatCurrency) {
        showWithdrawTransactionFlow(currency)
    }

    private func showWithdrawTransactionFlow(_ currency: FiatCurrency) {
        dismiss { [weak self] in
            guard let self = self else { return }
            self.accountProviding
                .accounts(for: .fiat(currency))
                .compactMap(\.first)
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] account in
                    self?.tabSwapping.withdraw(from: account)
                })
                .disposed(by: self.disposeBag)
        }
    }

    public func previous() {
        navigationRouter.dismiss()
    }

    /// Dismiss all presented ViewControllers and then execute callback.
    private func dismiss(completion: (() -> Void)? = nil) {
        var root: UIViewController? = navigationRouter.topMostViewControllerProvider.topMostViewController
        while root?.presentingViewController != nil {
            root = root?.presentingViewController
        }
        root?
            .dismiss(
                animated: true,
                completion: {
                    completion?()
                }
            )
    }

    private lazy var sheetPresenter: BottomSheetPresenting = BottomSheetPresenting(ignoresBackgroundTouches: false)
}
