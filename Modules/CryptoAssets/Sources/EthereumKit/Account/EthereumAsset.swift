// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class EthereumAsset: CryptoAsset {

    // MARK: - Properties

    let asset: CryptoCurrency

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        repository.defaultSingleAccount(network: network)
    }

    var canTransactToCustodial: AnyPublisher<Bool, Never> {
        cryptoAssetRepository.canTransactToCustodial
    }

    // MARK: - Private properties

    private lazy var cryptoAssetRepository: CryptoAssetRepositoryAPI = CryptoAssetRepository(
        asset: asset,
        errorRecorder: errorRecorder,
        kycTiersService: kycTiersService,
        defaultAccountProvider: { [repository, network] in
            repository.defaultSingleAccount(network: network)
        },
        exchangeAccountsProvider: exchangeAccountProvider,
        addressFactory: addressFactory
    )

    private let addressFactory: EthereumExternalAssetAddressFactory
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let network: EVMNetwork
    private let repository: EthereumWalletAccountRepositoryAPI

    // MARK: - Setup

    init(
        network: EVMNetwork,
        repository: EthereumWalletAccountRepositoryAPI = resolve(),
        addressFactory: EthereumExternalAssetAddressFactory = .init(),
        errorRecorder: ErrorRecording = resolve(),
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.network = network
        asset = network.cryptoCurrency
        self.addressFactory = addressFactory
        self.exchangeAccountProvider = exchangeAccountProvider
        self.repository = repository
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
    }

    // MARK: - Methods

    func initialize() -> AnyPublisher<Void, AssetError> {
        guard network == .ethereum else {
            return .just(())
        }
        // Run wallet renaming procedure on initialization.
        return cryptoAssetRepository.nonCustodialGroup
            .map(\.accounts)
            .flatMap { [upgradeLegacyLabels] accounts in
                upgradeLegacyLabels(accounts)
            }
            .mapError()
            .eraseToAnyPublisher()
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.accountGroup(filter: filter)
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        cryptoAssetRepository.parse(address: address)
    }

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        cryptoAssetRepository.parse(address: address, label: label, onTxCompleted: onTxCompleted)
    }
}

extension EthereumWalletAccountRepositoryAPI {

    fileprivate func defaultSingleAccount(network: EVMNetwork) -> AnyPublisher<SingleAccount, CryptoAssetError> {
        defaultAccount
            .mapError(CryptoAssetError.failedToLoadDefaultAccount)
            .map { account -> SingleAccount in
                EthereumCryptoAccount(
                    network: network,
                    publicKey: account.publicKey,
                    label: account.label,
                    hdAccountIndex: account.index
                )
            }
            .eraseToAnyPublisher()
    }
}
