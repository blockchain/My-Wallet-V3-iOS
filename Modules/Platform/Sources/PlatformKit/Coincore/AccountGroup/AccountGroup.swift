// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import Combine
import DIKit
import MoneyKit
import ObservabilityKit
import ToolKit

// swiftformat:disable all

/// An account group error.
public enum AccountGroupError: Error {

    case noBalance

    case noReceiveAddress

    /// No accounts in account group.
    case noAccounts
}

/// A `BlockchainAccount` that represents a collection of accounts, opposed to a single account.
public protocol AccountGroup: BlockchainAccount {
    var accounts: [SingleAccount] { get }

    func includes(account: BlockchainAccount) -> Bool

    var activityStream: AnyPublisher<[ActivityItemEvent], Error> { get }
}

extension AccountGroup {

    public var activityStream: AnyPublisher<[ActivityItemEvent], Error> {
        accounts
            .chunks(ofCount: 50)
            .map { accounts in
                accounts
                    .map { account in
                        account.activity
                            .replaceError(with: [ActivityItemEvent]())
                            .prepend([])
                            .eraseToAnyPublisher()
                    }
                    .combineLatest()
            }
            .combineLatest()
            .map { (result: [[[ActivityItemEvent]]]) -> [ActivityItemEvent] in
                result
                    .flatMap { $0 }
                    .flatMap { $0 }
                    .unique
                    .sorted(by: >)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    public var activity: AnyPublisher<[ActivityItemEvent], Error> {
        accounts
            .chunks(ofCount: 50)
            .map { accounts in
                accounts
                    .map { account in
                        account.activity
                            .replaceError(with: [ActivityItemEvent]())
                            .eraseToAnyPublisher()
                    }
                    .zip()
            }
            .zip()
            .map { (result: [[[ActivityItemEvent]]]) -> [ActivityItemEvent] in
                result
                    .flatMap { $0 }
                    .flatMap { $0 }
                    .unique
                    .sorted(by: >)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    public var currencyType: CurrencyType {
        guard let type = accounts.first?.currencyType else {
            fatalError("AccountGroup should have at least one account")
        }
        return type
    }

    public func fiatBalance(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<MoneyValue, Error> {
        guard accounts.isNotEmpty else {
            let logService: LogMessageServiceAPI = DIKit.resolve()
            logService.logError(
                message: "No accounts error - \(#function)",
                properties: [
                    "currency": fiatCurrency.code,
                    "time": time.timestamp ?? ""
                ]
            )
            return .failure(AccountGroupError.noAccounts)
        }
        return accounts
            .chunks(ofCount: 100)
            .map { accounts in
                accounts
                    .map { account in
                        account.fiatBalance(fiatCurrency: fiatCurrency, at: time)
                            .replaceError(with: MoneyValue.zero(currency: fiatCurrency))
                    }
                    .zip()
            }
            .zip()
            .tryMap { (balances: [[MoneyValue]]) -> MoneyValue in
                try balances.flatMap { $0 }
                    .reduce(MoneyValue.zero(currency: fiatCurrency), +)
            }
            .eraseToAnyPublisher()
    }

    public func fiatMainBalanceToDisplay(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<MoneyValue, Error> {
        guard accounts.isNotEmpty else {
            let logService: LogMessageServiceAPI = DIKit.resolve()
            logService.logError(
                message: "No accounts error - \(#function)",
                properties: [
                    "currency": fiatCurrency.code,
                    "time": time.timestamp ?? ""
                ]
            )
            return .failure(AccountGroupError.noAccounts)
        }
        return accounts
            .chunks(ofCount: 100)
            .map { accounts in
                accounts
                    .map { account in
                        account.fiatMainBalanceToDisplay(fiatCurrency: fiatCurrency, at: time)
                            .replaceError(with: MoneyValue.zero(currency: fiatCurrency))
                    }
                    .zip()
            }
            .zip()
            .tryMap { (balances: [[MoneyValue]]) -> MoneyValue in
                try balances.flatMap { $0 }
                    .reduce(MoneyValue.zero(currency: fiatCurrency), +)
            }
            .eraseToAnyPublisher()
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        guard accounts.isNotEmpty else {
            let logService: LogMessageServiceAPI = DIKit.resolve()
            logService.logError(
                message: "No accounts error - \(#function)",
                properties: [
                    "currency": fiatCurrency.code,
                    "time": time.timestamp ?? ""
                ]
            )
            return .failure(AccountGroupError.noAccounts)
        }

        return accounts
            .chunks(ofCount: 100)
            .map { accounts in
                accounts
                    .map { account in
                        account.balancePair(fiatCurrency: fiatCurrency, at: time)
                            .replaceError(
                                with: .zero(
                                    baseCurrency: account.currencyType,
                                    quoteCurrency: fiatCurrency.currencyType
                                )
                            )
                    }
                    .zip()
            }
            .zip()
            .tryMap { (balancePairs: [[MoneyValuePair]]) in
                try balancePairs.flatMap { $0 }
                    .reduce(
                        .zero(
                            baseCurrency: currencyType,
                            quoteCurrency: fiatCurrency.currencyType
                        ),
                        +
                    )
            }
            .eraseToAnyPublisher()
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        guard accounts.isNotEmpty else {
            let logService: LogMessageServiceAPI = DIKit.resolve()
            logService.logError(
                message: "No accounts error - \(#function)",
                properties: [
                    "currency": fiatCurrency.code,
                    "time": time.timestamp ?? ""
                ]
            )
            return .failure(AccountGroupError.noAccounts)
        }

        return accounts
            .chunks(ofCount: 100)
            .map { accounts in
                accounts
                    .map { account in
                        account.mainBalanceToDisplayPair(fiatCurrency: fiatCurrency, at: time)
                            .replaceError(
                                with: .zero(
                                    baseCurrency: account.currencyType,
                                    quoteCurrency: fiatCurrency.currencyType
                                )
                            )
                    }
                    .zip()
            }
            .zip()
            .tryMap { (balancePairs: [[MoneyValuePair]]) in
                try balancePairs.flatMap { $0 }
                    .reduce(
                        .zero(
                            baseCurrency: currencyType,
                            quoteCurrency: fiatCurrency.currencyType
                        ),
                        +
                    )
            }
            .eraseToAnyPublisher()
    }

    public func includes(account: BlockchainAccount) -> Bool {
        accounts.map(\.identifier).contains(account.identifier)
    }

    public func invalidateAccountBalance() {
        accounts.forEach { $0.invalidateAccountBalance() }
    }

    public var actions: AnyPublisher<AvailableActions, Error> {
        accounts
            .map(\.actions)
            .zip()
            .map { actions -> AvailableActions in
                actions.reduce(into: AvailableActions()) { $0.formUnion($1) }
            }
            .eraseToAnyPublisher()
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        accounts
            .map { $0.can(perform: action) }
            .flatMapConcatFirst()
            .eraseToAnyPublisher()
    }

    public var accountType: AccountType { .group }

    public var isFunded: AnyPublisher<Bool, Error> {
        guard !accounts.isEmpty else {
            return .just(false)
        }
        return accounts
            .map(\.isFunded)
            .zip()
            .map { values -> Bool in
                values.contains(true)
            }
            .eraseToAnyPublisher()
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        guard !accounts.isEmpty else {
            return .failure(AccountGroupError.noAccounts)
        }
        return accounts
            .map(\.pendingBalance)
            .zip()
            .tryMap { [currencyType] values -> MoneyValue in
                try values.reduce(.zero(currency: currencyType), +)
            }
            .eraseToAnyPublisher()
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        guard !accounts.isEmpty else {
            return .failure(AccountGroupError.noAccounts)
        }
        return accounts
            .map(\.balance)
            .zip()
            .tryMap { [currencyType] values -> MoneyValue in
                try values.reduce(.zero(currency: currencyType), +)
            }
            .eraseToAnyPublisher()
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        guard !accounts.isEmpty else {
            return .failure(AccountGroupError.noAccounts)
        }
        return accounts
            .map(\.actionableBalance)
            .zip()
            .tryMap { [currencyType] values -> MoneyValue in
                try values.reduce(.zero(currency: currencyType), +)
            }
            .eraseToAnyPublisher()
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(ReceiveAddressError.notSupported)
    }
}

extension AnyPublisher where Output == [AccountGroup?] {
    public func flatMapAllAccountGroup() -> AnyPublisher<AccountGroup?, Failure> {
        map { groups in
            let compactedGroup = groups.compactMap { $0 }

            guard compactedGroup.isEmpty == false else {
                return nil
            }
            return AllAccountsGroup(
                accounts: compactedGroup.map(\.accounts).flatMap { $0 }
            )
        }
        .eraseToAnyPublisher()
    }
}
