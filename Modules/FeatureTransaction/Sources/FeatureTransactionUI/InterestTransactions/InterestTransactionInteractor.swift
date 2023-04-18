// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

public protocol InterestTransactionRouting: AnyObject {

    /// Routes to the withdraw TransactionFlow with a given `CryptoInterestAccount`
    func startWithdraw(target: CryptoTradingAccount, sourceAccount: CryptoInterestAccount)

    /// Routes to the transfer TransactonFlow with a given `CryptoInterestAccount`
    func startTransfer(target: CryptoInterestAccount, sourceAccount: CryptoAccount?)

    /// Routes to the transfer TransactonFlow with a given `CryptoStakingAccount`
    func startDeposit(target: CryptoStakingAccount, sourceAccount: CryptoAccount?)
    func startWithdraw(target: CryptoTradingAccount, sourceAccount: CryptoStakingAccount)

    /// Routes to the transfer TransactionFlow with a give `CryptoActiveRewardsAccount`
    func startDeposit(target: CryptoActiveRewardsAccount, sourceAccount: CryptoAccount?)
    func startWithdraw(target: CryptoActiveRewardsWithdrawTarget, sourceAccount: CryptoActiveRewardsAccount)

    /// Exits the TransactonFlow
    func dismissTransactionFlow()

    /// Starts the interest transaction flow.
    func start()
}

extension InterestTransactionRouting where Self: RIBs.Router<InterestTransactionInteractable> {
    func start() {
        load()
    }
}

protocol InterestTransactionListener: ViewListener {}

final class InterestTransactionInteractor: Interactor, InterestTransactionInteractable, InterestTransactionListener {

    enum InterestTransactionType {
        case withdraw(CryptoInterestAccount, CryptoTradingAccount)
        case transfer(CryptoInterestAccount)
        case stake(CryptoStakingAccount)
        case stakingWithdraw(CryptoStakingAccount, CryptoTradingAccount)
        case activeRewardsDeposit(CryptoActiveRewardsAccount)
        case activeRewardsWithdraw(CryptoActiveRewardsAccount, CryptoActiveRewardsWithdrawTarget)
    }

    var publisher: AnyPublisher<TransactionFlowResult, Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<TransactionFlowResult, Never>()
    private var cancellables = Set<AnyCancellable>()

    weak var router: InterestTransactionRouting?
    weak var listener: InterestTransactionListener?

    // MARK: - Private Properties

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let transactionType: InterestTransactionType

    init(
        transactionType: InterestTransactionType,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.transactionType = transactionType
        self.analyticsRecorder = analyticsRecorder
        super.init()
    }

    deinit {
        subject.send(completion: .finished)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        switch transactionType {
        case .stake(let account):
            router?.startDeposit(target: account, sourceAccount: nil)
        case .stakingWithdraw(let source, let target):
            router?.startWithdraw(target: target, sourceAccount: source)
        case .transfer(let account):
            router?.startTransfer(target: account, sourceAccount: nil)
        case .withdraw(let source, let target):
            router?.startWithdraw(target: target, sourceAccount: source)
        case .activeRewardsDeposit(let account):
            router?.startDeposit(target: account, sourceAccount: nil)
        case .activeRewardsWithdraw(let account, let target):
            router?.startWithdraw(target: target, sourceAccount: account)
        }
    }

    func dismissTransactionFlow() {
        router?.dismissTransactionFlow()
        subject.send(.completed)
    }

    func presentKYCFlowIfNeeded(
        from viewController: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        unimplemented()
    }

    func presentKYCUpgradeFlow(
        from viewController: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        unimplemented()
    }
}
