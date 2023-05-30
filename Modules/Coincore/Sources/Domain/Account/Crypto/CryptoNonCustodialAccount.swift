// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine

public protocol CryptoNonCustodialAccount: CryptoAccount, NonCustodialAccount {

    func updateLabel(_ newLabel: String) -> AnyPublisher<Void, Never>

    /// Creates and return a On Chain `TransactionEngine` for this account `CryptoCurrency`.
    func createTransactionEngine() -> Any
}

extension CryptoNonCustodialAccount {

    public var accountType: AccountType {
        .nonCustodial
    }

    public var isBitPaySupported: Bool {
        if asset == .bitcoin {
            return true
        }

        return false
    }

    public func updateLabel(_ newLabel: String) -> AnyPublisher<Void, Never> {
        .just(())
    }
}
