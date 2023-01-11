// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import RxSwift
import ToolKit

public enum BlockchainAccountRepositoryError: Error {
    case coinCoreError(Error)
    case noAccount
}

public protocol BlockchainAccountRepositoryAPI: AnyObject {

    func fetchAccountWithAddresss(
        _ address: String,
        currencyType: CurrencyType
    ) -> AnyPublisher<BlockchainAccount, BlockchainAccountRepositoryError>

    func accountsAvailableToPerformAction(
        _ assetAction: AssetAction,
        target: BlockchainAccount
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError>

    func accountsWithCurrencyType(
        _ currency: CurrencyType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError>

    func accountsWithSingleAccountType(
        _ accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError>

    func accountsWithCurrencyType(
        _ currency: CurrencyType, accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError>

    func accountWithCurrencyType(
        _ currency: CurrencyType, accountType: SingleAccountType
    ) -> AnyPublisher<BlockchainAccount, BlockchainAccountRepositoryError>
}

public protocol BlockchainAccountProviding: AnyObject {
    func accounts(for currency: CurrencyType) -> Single<[BlockchainAccount]>
    func accounts(accountType: SingleAccountType) -> Single<[BlockchainAccount]>
    func accounts(for currency: CurrencyType, accountType: SingleAccountType) -> Single<[BlockchainAccount]>
    func account(for currency: CurrencyType, accountType: SingleAccountType) -> Single<BlockchainAccount>
}

public enum BlockchainAccountProvidingError: Error {
    case doesNotExist
}

final class BlockchainAccountProvider: BlockchainAccountProviding, BlockchainAccountRepositoryAPI {
    private let coincore: CoincoreAPI
    private let app: AppProtocol

    init(
        coincore: CoincoreAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.coincore = coincore
        self.app = app
    }

    // MARK: - BlockchainAccountRepositoryAPI

    func fetchAccountWithAddresss(
        _ address: String,
        currencyType: CurrencyType
    ) -> AnyPublisher<BlockchainAccount, BlockchainAccountRepositoryError> {
        coincore
            .allAccounts(filter: .allExcludingExchange)
            .map(\.accounts)
            .map { $0.filter { $0.currencyType == currencyType } }
            .eraseError()
            .flatMapFilter(address: address)
            .map { $0 as BlockchainAccount }
            .mapError(BlockchainAccountRepositoryError.coinCoreError)
            .eraseToAnyPublisher()
    }

    func accountsAvailableToPerformAction(
        _ assetAction: AssetAction,
        target: BlockchainAccount
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError> {
        coincore
            .allAccounts(filter: .allExcludingExchange)
            .map(\.accounts)
            .eraseError()
            .flatMapFilter(action: assetAction)
            .map { $0.map { $0 as BlockchainAccount } }
            .mapError(BlockchainAccountRepositoryError.coinCoreError)
            .eraseToAnyPublisher()
    }

    func accountsWithCurrencyType(
        _ currency: CurrencyType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError> {
        coincore
            .allAccounts(filter: .allExcludingExchange)
            .map { $0.accounts.filter { $0.currencyType == currency } }
            .mapError(BlockchainAccountRepositoryError.coinCoreError)
            .eraseToAnyPublisher()
    }

    func accountsWithSingleAccountType(
        _ accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError> {
        coincore
            .allAccounts(filter: .allExcludingExchange)
            .map(\.accounts)
            .map { accounts in
                accounts.filter { account in
                    switch accountType {
                    case .nonCustodial:
                        return account is NonCustodialAccount
                    case .custodial(let type):
                        switch type {
                        case .savings:
                            return account is CryptoInterestAccount || account is CryptoStakingAccount || account is CryptoActiveRewardsAccount
                        case .trading:
                            return account is TradingAccount
                        }
                    }
                }
            }
            .mapError(BlockchainAccountRepositoryError.coinCoreError)
            .eraseToAnyPublisher()
    }

    func accountsWithCurrencyType(
        _ currency: CurrencyType, accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError> {
        switch currency {
        case .fiat:
            return coincore.fiatAsset
                .accountGroup(filter: .allExcludingExchange)
                .compactMap { $0 }
                .map(\.accounts)
                .map { accounts in
                    accounts.filter { $0.currencyType == currency }
                }
                .map { accounts in
                    accounts as [BlockchainAccount]
                }
                .mapError(BlockchainAccountRepositoryError.coinCoreError)
                .eraseToAnyPublisher()

        case .crypto(let cryptoCurrency):
            guard let cryptoAsset = coincore.cryptoAssets.first(where: { $0.asset == cryptoCurrency }) else {
                return .just([])
            }

            let filter: AssetFilter

            switch accountType {
            case .nonCustodial:
                filter = .nonCustodial
            case .custodial(let type):
                switch type {
                case .savings:
                    filter = .interest
                case .trading:
                    filter = .custodial
                }
            }

            return cryptoAsset
                .accountGroup(filter: filter)
                .compactMap { $0 }
                .map(\.accounts)
                .map { accounts in
                    accounts.filter { $0.currencyType == currency }
                }
                .map { accounts in
                    accounts as [BlockchainAccount]
                }
                .mapError(BlockchainAccountRepositoryError.coinCoreError)
                .eraseToAnyPublisher()
        }
    }

    func accountWithCurrencyType(
        _ currency: CurrencyType, accountType: SingleAccountType
    ) -> AnyPublisher<BlockchainAccount, BlockchainAccountRepositoryError> {
        accountsWithCurrencyType(currency, accountType: accountType)
            .flatMap { accounts -> AnyPublisher<BlockchainAccount, BlockchainAccountRepositoryError> in
                guard let value = accounts.first else {
                    return .failure(BlockchainAccountRepositoryError.noAccount)
                }
                return .just(value)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - BlockchainAccountProviding

    func accounts(for currency: CurrencyType) -> Single<[BlockchainAccount]> {
        coincore
            .allAccounts(filter: .allExcludingExchange)
            .asSingle()
            .map { $0.accounts.filter { $0.currencyType == currency } }
            .catchAndReturn([])
    }

    func accounts(accountType: SingleAccountType) -> Single<[BlockchainAccount]> {
        coincore
            .allAccounts(filter: .allExcludingExchange)
            .asSingle()
            .map(\.accounts)
            .map { accounts in
                accounts.filter { account in
                    switch accountType {
                    case .nonCustodial:
                        return account is NonCustodialAccount
                    case .custodial(let type):
                        switch type {
                        case .savings:
                            return account is CryptoInterestAccount || account is CryptoStakingAccount || account is CryptoActiveRewardsAccount
                        case .trading:
                            return account is TradingAccount
                        }
                    }
                }
            }
            .catchAndReturn([])
    }

    func accounts(for currency: CurrencyType, accountType: SingleAccountType) -> Single<[BlockchainAccount]> {
        switch currency {
        case .fiat:
            return coincore.fiatAsset
                .accountGroup(filter: .allExcludingExchange)
                .compactMap { $0 }
                .map(\.accounts)
                .map { accounts in
                    accounts.filter { $0.currencyType == currency }
                }
                .map { accounts in
                    accounts as [BlockchainAccount]
                }
                .replaceError(with: [])
                .asSingle()
        case .crypto(let cryptoCurrency):
            let cryptoAsset = coincore[cryptoCurrency]

            return app.modePublisher()
                .flatMap { appMode in
                    cryptoAsset
                        .accountGroup(filter: appMode.filter)
                }
                .compactMap { $0 }
                .map(\.accounts)
                .map { accounts in
                    accounts.filter { $0.currencyType == currency }
                }
                .map { accounts in
                    accounts as [BlockchainAccount]
                }
                .replaceError(with: [])
                .asSingle()
        }
    }

    func account(for currency: CurrencyType, accountType: SingleAccountType) -> Single<BlockchainAccount> {
        accounts(for: currency, accountType: accountType)
            .flatMap { accounts in
                guard let value = accounts.first else {
                    return .error(BlockchainAccountProvidingError.doesNotExist)
                }
                return .just(value)
            }
    }
}
