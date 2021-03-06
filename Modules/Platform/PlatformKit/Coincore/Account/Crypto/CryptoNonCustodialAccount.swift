// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CryptoNonCustodialAccount: CryptoAccount, NonCustodialAccount {
    func updateLabel(_ newLabel: String) -> Completable
    /// Creates and return a On Chain `TransactionEngine` for this account `CryptoCurrency`.
    func createTransactionEngine() -> Any
}

extension CryptoNonCustodialAccount {
    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var isFunded: Single<Bool> {
        balance
            .map { $0.isPositive }
    }

    public func updateLabel(_ newLabel: String) -> Completable {
        .error(PlatformKitError.illegalStateException(message: "Cannot update account label for \(asset.name) accounts"))
    }
}
