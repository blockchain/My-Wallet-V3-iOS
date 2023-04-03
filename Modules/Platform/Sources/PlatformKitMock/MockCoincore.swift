// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxSwift

final class MockCoincore: CoincoreAPI {
    func account(
        where isIncluded: @escaping (BlockchainAccount) -> Bool
    ) -> AnyPublisher<[BlockchainAccount], Error> {
        .empty()
    }

    func accounts(
        filter: AssetFilter,
        where isIncluded: @escaping (BlockchainAccount) -> Bool
    ) -> AnyPublisher<[BlockchainAccount], Error> {
        .empty()
    }

    var allAssets: [Asset] = []
    var fiatAsset: Asset = MockAsset()
    var cryptoAssets: [CryptoAsset] = [MockAsset()]
    var initializePublisherCalled = false

    func initialize() -> AnyPublisher<Void, CoincoreError> {
        initializePublisherCalled = true
        return .just(())
    }

    func getTransactionTargets(
        sourceAccount: BlockchainAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], CoincoreError> {
        .just([])
    }

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
        cryptoAssets.first(where: { $0.asset == cryptoCurrency })!
    }

    func allAccounts(filter: AssetFilter) -> AnyPublisher<AccountGroup, CoincoreError> {
        .empty()
    }
}

class MockAccountGroup: AccountGroup {

    let accounts: [SingleAccount]
    let currencyType: CurrencyType
    let identifier: AnyHashable
    let label: String
    let assetName: String

    init(
        accounts: [SingleAccount] = [],
        currencyType: CurrencyType,
        identifier: AnyHashable = "MockAccountGroup",
        label: String = "MockAccountGroup"
    ) {
        self.accounts = accounts
        self.currencyType = currencyType
        self.identifier = identifier
        self.label = label
        self.assetName = ""
    }
}

class MockAsset: CryptoAsset {

    struct ExternalAddress: ExternalAssetAddressFactory {

        func makeExternalAssetAddress(
            address: String,
            label: String,
            onTxCompleted: @escaping TxCompleted
        ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
            .failure(.invalidAddress)
        }
    }

    var accountGroup: AccountGroup = MockAccountGroup(currencyType: .crypto(.bitcoin))

    var asset: CryptoCurrency {
        accountGroup.currencyType.cryptoCurrency!
    }

    var addressFactory: ExternalAssetAddressFactory = ExternalAddress()

    func initialize() -> AnyPublisher<Void, AssetError> {
        .just(())
    }

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        guard let account = accountGroup.accounts.first else {
            return .failure(.noDefaultAccount)
        }
        return .just(account)
    }

    var canTransactToCustodial: AnyPublisher<Bool, Never> {
        .just(true)
    }

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        .failure(.invalidAddress)
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {
        .just(accountGroup)
    }

    func transactionTargets(account: SingleAccount) -> AnyPublisher<[SingleAccount], Never> {
        .just(accountGroup.accounts)
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        .just(nil)
    }
}
