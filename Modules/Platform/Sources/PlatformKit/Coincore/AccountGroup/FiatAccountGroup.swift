// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import MoneyKit

/// An `AccountGroup` containing only fiat accounts.
public class FiatAccountGroup: AccountGroup {

    private typealias LocalizedString = LocalizationConstants.AccountGroup

    public private(set) lazy var identifier: AnyHashable = "FiatAccountGroup"

    public let label: String
    public let assetName: String = ""

    public let accounts: [SingleAccount]

    public var accountType: AccountType = .group

    public var isFunded: AnyPublisher<Bool, Error> {
        .failure(AccountGroupError.noBalance)
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(AccountGroupError.noReceiveAddress)
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        .failure(AccountGroupError.noBalance)
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .failure(AccountGroupError.noBalance)
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        .failure(AccountGroupError.noBalance)
    }

    public func invalidateAccountBalance() {
        accounts.forEach { $0.invalidateAccountBalance() }
    }

    public init(accounts: [SingleAccount]) {
        self.label = "Fiat Accounts"
        self.accounts = accounts
    }
}
