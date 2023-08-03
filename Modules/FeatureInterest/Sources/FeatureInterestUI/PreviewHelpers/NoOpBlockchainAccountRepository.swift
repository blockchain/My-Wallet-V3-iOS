// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Coincore
import Combine
import FeatureInterestDomain
import MoneyKit

final class NoOpBlockchainAccountRepository: BlockchainAccountRepositoryAPI {
    func accountsWithCurrencyType(
        _ currency: CurrencyType,
        accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError> {
        Empty().eraseToAnyPublisher()
    }

    func accountWithCurrencyType(
        _ currency: CurrencyType,
        accountType: SingleAccountType
    ) -> AnyPublisher<BlockchainAccount, BlockchainAccountRepositoryError> {
        Empty().eraseToAnyPublisher()
    }

    func accountsAvailableToPerformAction(
        _ assetAction: AssetAction,
        target: BlockchainAccount
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError> {
        Empty().eraseToAnyPublisher()
    }
}
