// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import FeatureTransactionUI
import MoneyKit
import PlatformKit
import UIKit

/// Represents all types of transactions the user can perform.
enum TransactionType: Equatable {

    /// Performs a buy. If `CrytoAccount` is `nil`, the users will be presented with a crypto currency selector.
    case buy(CryptoAccount?)
    /// Performs a sell. If `CrytoCurrency` is `nil`, the users will be presented with a crypto currency selector.
    case sell(CryptoAccount?)
    /// Performs a swap. If `CrytoCurrency` is `nil`, the users will be presented with a crypto currency selector.
    case swap(CryptoAccount?)
    /// Shows details to receive crypto.
    case receive(CryptoAccount?)
    /// Performs an interest transfer.
    case interestTransfer(CryptoInterestAccount)
    /// Performs an interest withdraw.
    case interestWithdraw(CryptoInterestAccount, CryptoTradingAccount)

    case sign(sourceAccount: CryptoAccount, destination: TransactionTarget)

    static func == (lhs: TransactionType, rhs: TransactionType) -> Bool {
        switch (lhs, rhs) {
        case (.buy(let lhsAccount), .buy(let rhsAccount)):
            return lhsAccount?.identifier == rhsAccount?.identifier
        case (.sell(let lhsAccount), .sell(let rhsAccount)):
            return lhsAccount?.identifier == rhsAccount?.identifier
        case (.swap(let lhsAccount), .swap(let rhsAccount)):
            return lhsAccount?.identifier == rhsAccount?.identifier
        case (.receive(let lhsAccount), .receive(let rhsAccount)):
            return lhsAccount?.identifier == rhsAccount?.identifier
        case (.interestTransfer(let lhsAccount), .interestTransfer(let rhsAccount)):
            return lhsAccount.identifier == rhsAccount.identifier
        case (.interestWithdraw(let lhsFromAccount, let lhsToAccount), .interestWithdraw(let rhsFromAccount, let rhsToAccount)):
            return lhsFromAccount.identifier == rhsFromAccount.identifier && lhsToAccount.identifier == rhsToAccount.identifier
        case (.sign(let lhsSourceAccount, let lhsDestination), .sign(let rhsSourceAccount, let rhsDestination)):
            return lhsSourceAccount.identifier == rhsSourceAccount.identifier
            && lhsDestination.label == rhsDestination.label
        default:
            return false
        }
    }
}

/// Represents the possible outcomes of going through the transaction flow.
public enum TransactionResult: Equatable {
    case abandoned
    case completed
}

/// A protocol defining the API for the app's entry point to any `Transaction Flow`. The app should only use this interface to let users perform any kind of transaction.
/// NOTE: Presenting a Transaction Flow can never fail because it's expected for any error to be handled within the flow. Non-recoverable errors should force the user to abandon the flow.
protocol TransactionsAdapterAPI {

    /// Presents a Transactions Flow for the passed-in type of transaction to perform using the `presenter` as a starting point.
    /// - Parameters:
    ///   - transactionToPerform: The desireed type of transaction to be performed.
    ///   - presenter: The `ViewController` used to present the Transaction Flow.
    ///   - completion: A closure called when the user has completed or abandoned the Transaction Flow.
    func presentTransactionFlow(
        to transactionToPerform: TransactionType,
        from presenter: UIViewController,
        completion: @escaping (TransactionResult) -> Void
    )

    /// Presents a Transactions Flow for the passed-in type of transaction to perform using the `presenter` as a starting point.
    /// - Parameters:
    ///   - transactionToPerform: The desireed type of transaction to be performed.
    ///   - presenter: The `ViewController` used to present the Transaction Flow.
    /// - Returns: A `Combine.Publisher` that publishes a `TransactionResult` once and never fails.
    func presentTransactionFlow(
        to transactionToPerform: TransactionType,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionResult, Never>
}

// MARK: - Interface Implementation

extension TransactionType {

    fileprivate var transactionFlowActionValue: TransactionFlowAction {
        switch self {
        case .buy(let cryptoAccount):
            return .buy(cryptoAccount)
        case .sell(let cryptoAccount):
            return .sell(cryptoAccount)
        case .swap(let cryptoAccount):
            return .swap(cryptoAccount)
        case .receive(let cryptoAccount):
            return .receive(cryptoAccount)
        case .interestTransfer(let cryptoInterestAccount):
            return .interestTransfer(cryptoInterestAccount)
        case .interestWithdraw(let cryptoInterestAccount, let target):
            return .interestWithdraw(cryptoInterestAccount, target)
        case .sign(let sourceAccount, let destination):
            return .sign(sourceAccount: sourceAccount, destination: destination)
        }
    }
}

extension TransactionResult {

    fileprivate init(_ transactionFlowResult: TransactionFlowResult) {
        switch transactionFlowResult {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

final class TransactionsAdapter: TransactionsAdapterAPI {

    private let router: FeatureTransactionUI.TransactionsRouterAPI
    private let coincore: CoincoreAPI
    private let app: AppProtocol

    private var cancellables = Set<AnyCancellable>()

    init(
        router: FeatureTransactionUI.TransactionsRouterAPI,
        coincore: CoincoreAPI,
        app: AppProtocol
    ) {
        self.router = router
        self.coincore = coincore
        self.app = app
    }

    func presentTransactionFlow(
        to transactionToPerform: TransactionType,
        from presenter: UIViewController,
        completion: @escaping (TransactionResult) -> Void
    ) {
        presentTransactionFlow(to: transactionToPerform, from: presenter)
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }

    func presentTransactionFlow(
        to transactionToPerform: TransactionType,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionResult, Never> {
        router.presentTransactionFlow(
            to: transactionToPerform.transactionFlowActionValue,
            from: presenter
        )
        .map(TransactionResult.init)
        .eraseToAnyPublisher()
    }

    func presentTransactionFlow(
        toBuy cryptoCurrency: CryptoCurrency,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionResult, Never> {
        app.modePublisher()
            .flatMap { [coincore] appMode in
                coincore.cryptoAccounts(
                    for: .bitcoin,
                    supporting: .buy,
                    filter: appMode.filter
                )
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] accounts -> AnyPublisher<TransactionResult, Never> in
                guard let self else {
                    return .empty()
                }
                return self.presentTransactionFlow(to: .buy(accounts.first), from: presenter)
            }
            .eraseToAnyPublisher()
    }
}
