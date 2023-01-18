// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import DIKit
import FeatureCryptoDomainDomain
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class EVMAsset: CryptoAsset {

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
        nonCustodialAccountsProvider: { [repository, network] in
            repository
                .defaultSingleAccount(network: network)
                .map { [$0] }
                .eraseToAnyPublisher()
        },
        exchangeAccountsProvider: exchangeAccountProvider,
        addressFactory: addressFactory,
        featureFlag: featureFlag
    )

    private let keyPairProvider: EthereumKeyPairProvider
    private let addressFactory: EthereumExternalAssetAddressFactory
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let network: EVMNetwork
    private let repository: EthereumWalletAccountRepository
    private let featureFlag: FeatureFetching

    // MARK: - Setup

    init(
        network: EVMNetwork,
        keyPairProvider: EthereumKeyPairProvider,
        repository: EthereumWalletAccountRepository,
        addressFactory: EthereumExternalAssetAddressFactory,
        errorRecorder: ErrorRecording,
        exchangeAccountProvider: ExchangeAccountsProviderAPI,
        kycTiersService: KYCTiersServiceAPI,
        featureFlag: FeatureFetching
    ) {
        self.network = network
        self.asset = network.nativeAsset
        self.addressFactory = addressFactory
        self.exchangeAccountProvider = exchangeAccountProvider
        self.repository = repository
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
        self.featureFlag = featureFlag
        self.keyPairProvider = keyPairProvider
    }

    // MARK: - Methods

    func initialize() -> AnyPublisher<Void, AssetError> {
        guard network == .ethereum else {
            return .just(())
        }
        // Run wallet renaming procedure on initialization.
        return cryptoAssetRepository
            .nonCustodialGroup
            .compactMap { $0 }
            .map(\.accounts)
            .map { accounts -> [EVMCryptoAccount] in
                accounts
                    .compactMap { $0 as? EVMCryptoAccount }
                    .filter { $0.labelNeedsForcedUpdate }
                    .map { $0 }
            }
            .flatMap { [repository] accounts -> AnyPublisher<Void, Never> in
                guard accounts.isNotEmpty else {
                    return .just(())
                }
                return repository.updateLabels(on: accounts)
                    .eraseToAnyPublisher()
            }
            .mapError()
            .eraseToAnyPublisher()
    }

    var subscriptionEntries: AnyPublisher<[SubscriptionEntry], Never> {
        keyPairProvider
            .keyPair
            .optional()
            .replaceError(with: nil)
            .map { [asset] keyPair -> [SubscriptionEntry] in
                guard let keyPair else {
                    return []
                }
                let entry = SubscriptionEntry(
                    currency: asset.code,
                    account: SubscriptionEntry.Account(
                        index: 0,
                        name: asset.defaultWalletName
                    ),
                    pubKeys: [
                        SubscriptionEntry.PubKey(
                            pubKey: keyPair.publicKey,
                            style: "SINGLE",
                            descriptor: 0
                        )
                    ]
                )
                return [entry]
            }
            .eraseToAnyPublisher()
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {
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

extension EVMAsset: DomainResolutionRecordProviderAPI {

    var resolutionRecord: AnyPublisher<ResolutionRecord, Error> {
        defaultAccount
            .eraseError()
            .flatMap { account in
                account.receiveAddress.eraseError()
            }
            .map { [asset] receiveAddress in
                ResolutionRecord(symbol: asset.code, walletAddress: receiveAddress.address)
            }
            .eraseToAnyPublisher()
    }
}

extension EthereumWalletAccountRepositoryAPI {

    fileprivate func defaultSingleAccount(network: EVMNetwork) -> AnyPublisher<SingleAccount, CryptoAssetError> {
        defaultAccount
            .mapError(CryptoAssetError.failedToLoadDefaultAccount)
            .map { account -> SingleAccount in
                EVMCryptoAccount(
                    network: network,
                    publicKey: account.publicKey,
                    label: account.label
                )
            }
            .eraseToAnyPublisher()
    }
}
