// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Coincore
import Combine
import FeatureInterestDomain
import MoneyKit
import ToolKit

final class BlockchainAccountRepository: BlockchainAccountRepositoryAPI {
    private let coincore: CoincoreAPI
    private let app: AppProtocol

    init(
        coincore: CoincoreAPI,
        app: AppProtocol
    ) {
        self.coincore = coincore
        self.app = app
    }

    // MARK: - BlockchainAccountRepositoryAPI

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
        _ currency: CurrencyType,
        accountType: SingleAccountType
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

            let filter: AssetFilter = switch accountType {
            case .nonCustodial:
                .nonCustodial
            case .custodial(let type):
                switch type {
                case .savings:
                    .interest
                case .trading:
                    .custodial
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
        _ currency: CurrencyType,
        accountType: SingleAccountType
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
}
