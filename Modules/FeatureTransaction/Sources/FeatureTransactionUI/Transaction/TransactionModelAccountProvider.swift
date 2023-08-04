// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift

/// Types adopting `SourceAndTargetAccountProviding` should provide access to the source and destination account
public protocol SourceAndTargetAccountProviding: AccountPickerAccountProviding {
    var sourceAccount: Single<BlockchainAccount?> { get }
    var destinationAccount: Observable<TransactionTarget?> { get }
}

final class TransactionModelAccountProvider: SourceAndTargetAccountProviding {

    private let transactionModel: TransactionModel

    var accounts: Observable<[BlockchainAccount]> {
        transactionModel
            .state
            .compactMap(transform)
            .flatMap(flatMap)
            .distinctUntilChanged { lhs, rhs in
                lhs.map(\.identifier) == rhs.map(\.identifier)
            }
    }

    var sourceAccount: Single<BlockchainAccount?> {
        transactionModel.state
            .map(\.source)
            .take(1)
            .asSingle()
    }

    var destinationAccount: Observable<TransactionTarget?> {
        transactionModel.state
            .map(\.destination)
    }

    private let transform: (TransactionState) -> [BlockchainAccount]?
    private let flatMap: ([BlockchainAccount]) -> Observable<[BlockchainAccount]>

    /// TransactionModelAccountProvider
    ///
    /// - parameter transactionModel: An `TransactionModel` which `state` will be observed.
    /// - parameter transform: A transform function to apply to each source element of `TransactionModel.state`.
    init(
        transactionModel: TransactionModel,
        transform: @escaping (TransactionState) -> [BlockchainAccount]?,
        flatMap: @escaping ([BlockchainAccount]) -> Observable<[BlockchainAccount]> = Observable.just
    ) {
        self.transactionModel = transactionModel
        self.transform = transform
        self.flatMap = flatMap
    }
}
