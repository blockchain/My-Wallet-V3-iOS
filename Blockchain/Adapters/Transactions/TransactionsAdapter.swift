// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit // TODO: replace with MoneyKit when available
import TransactionUIKit

/// Represents all types of transactions the user can perform.
enum TransactionType: Equatable {

    /// Performs a buy. If `CrytoCurrency` is `nil`, the users will be presented with a crypto currency selector.
    case buy(CryptoCurrency?)
}

/// Represents the possible outcomes of going through the transaction flow.
enum TransactionResult: Equatable {
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
        case .buy(let cryptoCurrency):
            return .buy(cryptoCurrency)
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

    private let router: TransactionUIKit.TransactionsRouterAPI
    private var cancellables = Set<AnyCancellable>()

    init(router: TransactionUIKit.TransactionsRouterAPI = resolve()) {
        self.router = router
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
        router.presentTransactionFlow(to: transactionToPerform.transactionFlowActionValue, from: presenter)
            .map(TransactionResult.init)
            .eraseToAnyPublisher()
    }
}
