// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureKYCDomain
import FeatureTransactionDomain
import PlatformKit
import RxSwift
import ToolKit

public class ReceiveCoordinator {

    // MARK: - Types

    private enum ReceiveAction {
        case presentReceiveScreen(account: BlockchainAccount)
        case presentKYCScreen
        case presentError
    }

    // MARK: - Public Properties

    public let builder: ReceiveRootBuilder

    // MARK: - Private Properties

    private let coincore: CoincoreAPI
    private let receiveRouter: ReceiveRouterAPI
    private let kycStatusChecker: KYCStatusChecking
    private let analyticsHook: TransactionAnalyticsHook
    private let receiveSelectionService: AccountSelectionServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        coincore: CoincoreAPI = resolve(),
        receiveRouter: ReceiveRouterAPI = resolve(),
        receiveSelectionService: AccountSelectionServiceAPI = AccountSelectionService(),
        kycStatusChecker: KYCStatusChecking = resolve(),
        analyticsHook: TransactionAnalyticsHook = resolve()
    ) {
        self.coincore = coincore
        self.receiveRouter = receiveRouter
        self.kycStatusChecker = kycStatusChecker
        self.analyticsHook = analyticsHook
        self.receiveSelectionService = receiveSelectionService
        self.builder = ReceiveRootBuilder(
            receiveSelectionService: receiveSelectionService
        )

        receiveSelectionService
            .selectedData
            .flatMapLatest(weak: self) { (self, account) -> Observable<ReceiveAction> in
                switch account {
                case let account as ReceivePlaceholderCryptoAccount:
                    return self.present(placeholderAccount: account)
                case is TradingAccount:
                    return self.didSelectTradingAccountForReceive(account: account)
                default:
                    return .just(.presentReceiveScreen(account: account))
                }
            }
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .presentReceiveScreen(let account):
                    self?.receiveRouter.presentReceiveScreen(for: account)
                case .presentKYCScreen:
                    self?.receiveRouter.presentKYCScreen()
                case .presentError:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Methods

    public func routeToReceive(sourceAccount: BlockchainAccount) {
        receiveSelectionService.record(selection: sourceAccount)
    }

    // MARK: - Private Methods

    private func present(placeholderAccount: ReceivePlaceholderCryptoAccount) -> Observable<ReceiveAction> {
        guard let asset = coincore[placeholderAccount.asset] else {
            return .just(.presentError)
        }

        return asset
            .defaultAccount
            .asObservable()
            .map { .presentReceiveScreen(account: $0) }
    }

    private func didSelectTradingAccountForReceive(account: BlockchainAccount) -> Observable<ReceiveAction> {
        kycStatusChecker.checkStatus()
            .map { status -> ReceiveAction in
                switch status {
                case .unverified, .verifying:
                    return .presentKYCScreen
                case .verified:
                    return .presentReceiveScreen(account: account)
                case .failed:
                    return .presentError
                }
            }
            .asObservable()
    }
}
