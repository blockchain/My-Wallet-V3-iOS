// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Coincore
import Combine
import MoneyKit

class AssetMock: CryptoAsset {

    struct ExternalAddress: ExternalAssetAddressFactory {

        func makeExternalAssetAddress(
            address: String,
            label: String,
            onTxCompleted: @escaping TxCompleted
        ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
            .failure(.invalidAddress)
        }
    }

    var accountGroup: AccountGroup = AccountGroupMock(currencyType: .crypto(.bitcoin))

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
        onTxCompleted: @escaping (TransactionResult) -> AnyPublisher<Void, Error>
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
