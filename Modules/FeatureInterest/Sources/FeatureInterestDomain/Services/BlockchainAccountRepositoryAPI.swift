// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Coincore
import Combine
import MoneyKit

public enum BlockchainAccountRepositoryError: Error {
    case coinCoreError(Error)
    case noAccount
}

public protocol BlockchainAccountRepositoryAPI: AnyObject {

    func accountsAvailableToPerformAction(
        _ assetAction: AssetAction,
        target: BlockchainAccount
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError>

    func accountsWithCurrencyType(
        _ currency: CurrencyType, accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccountRepositoryError>

    func accountWithCurrencyType(
        _ currency: CurrencyType, accountType: SingleAccountType
    ) -> AnyPublisher<BlockchainAccount, BlockchainAccountRepositoryError>
}
