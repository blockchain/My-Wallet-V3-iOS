// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Coincore
import Combine
import MoneyKit

class CoincoreMock: CoincoreAPI {
    func allAccounts(
        filter: Coincore.AssetFilter
    ) -> AnyPublisher<Coincore.AccountGroup, Coincore.CoincoreError> {
        .empty()
    }

    func accounts(
        filter: Coincore.AssetFilter,
        where isIncluded: @escaping (Coincore.BlockchainAccount) -> Bool
    ) -> AnyPublisher<[Coincore.BlockchainAccount], Error> {
        .empty()
    }

    func accounts(
        where isIncluded: @escaping (Coincore.BlockchainAccount) -> Bool
    ) -> AnyPublisher<[Coincore.BlockchainAccount], Error> {
        .empty()
    }

    var allAssets: [Asset] = []
    var fiatAsset: Asset = AssetMock()
    var cryptoAssets: [CryptoAsset] = [AssetMock()]
    var initializePublisherCalled = false

    func initialize() -> AnyPublisher<Void, Coincore.CoincoreError> {
        initializePublisherCalled = true
        return .just(())
    }

    func getTransactionTargets(
        sourceAccount: Coincore.BlockchainAccount,
        action: Coincore.AssetAction
    ) -> AnyPublisher<[Coincore.SingleAccount], Coincore.CoincoreError> {
        .just([])
    }

    subscript(cryptoCurrency: MoneyDomainKit.CryptoCurrency) -> Coincore.CryptoAsset? {
        cryptoAssets.first(where: { $0.asset == cryptoCurrency })
    }

    func account(_ identifier: String) -> AnyPublisher<Coincore.BlockchainAccount?, Never> {
        .empty()
    }
}
