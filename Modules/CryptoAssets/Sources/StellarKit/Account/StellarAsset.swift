// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import FeatureCryptoDomainDomain
import MoneyKit
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

final class StellarAsset: CryptoAsset {

    // MARK: - Properties

    let asset: CryptoCurrency = .stellar

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        stellarCryptoAccount
            .map { account -> SingleAccount in
                account
            }
            .eraseToAnyPublisher()
    }

    var canTransactToCustodial: AnyPublisher<Bool, Never> {
        cryptoAssetRepository.canTransactToCustodial
    }

    // MARK: - Private properties

    private lazy var cryptoAssetRepository: CryptoAssetRepositoryAPI = CryptoAssetRepository(
        asset: asset,
        errorRecorder: errorRecorder,
        kycTiersService: kycTiersService,
        nonCustodialAccountsProvider: { [defaultAccount] in
            defaultAccount
                .map { [$0] }
                .eraseToAnyPublisher()
        },
        exchangeAccountsProvider: exchangeAccountProvider,
        addressFactory: addressFactory,
        featureFlag: featureFlag
    )

    private var stellarCryptoAccount: AnyPublisher<StellarCryptoAccount, CryptoAssetError> {
        accountRepository
            .defaultAccount
            .setFailureType(to: CryptoAssetError.self)
            .onNil(CryptoAssetError.noDefaultAccount)
            .map { account -> StellarCryptoAccount in
                StellarCryptoAccount(
                    publicKey: account.publicKey,
                    label: account.label
                )
            }
            .eraseToAnyPublisher()
    }

    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let accountRepository: StellarWalletAccountRepositoryAPI
    private let errorRecorder: ErrorRecording
    private let addressFactory: StellarCryptoReceiveAddressFactory
    private let kycTiersService: KYCTiersServiceAPI
    private let featureFlag: FeatureFetching

    // MARK: - Setup

    init(
        accountRepository: StellarWalletAccountRepositoryAPI,
        errorRecorder: ErrorRecording,
        exchangeAccountProvider: ExchangeAccountsProviderAPI,
        kycTiersService: KYCTiersServiceAPI,
        addressFactory: StellarCryptoReceiveAddressFactory,
        featureFlag: FeatureFetching
    ) {
        self.exchangeAccountProvider = exchangeAccountProvider
        self.accountRepository = accountRepository
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
        self.addressFactory = addressFactory
        self.featureFlag = featureFlag
    }

    // MARK: - Methods

    func initialize() -> AnyPublisher<Void, AssetError> {
        accountRepository.initializeMetadata()
            .flatMap { [cryptoAssetRepository, upgradeLegacyLabels] _ in
                cryptoAssetRepository
                    .nonCustodialGroup
                    .compactMap { $0 }
                    .map(\.accounts)
                    .flatMap { [upgradeLegacyLabels] accounts in
                        upgradeLegacyLabels(accounts)
                    }
            }
            .mapError { _ in .initialisationFailed }
            .eraseToAnyPublisher()
    }

    var subscriptionEntries: AnyPublisher<[SubscriptionEntry], Never> {
        accountRepository
            .loadKeyPair()
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

extension StellarAsset: DomainResolutionRecordProviderAPI {

    var resolutionRecord: AnyPublisher<ResolutionRecord, Error> {
        defaultAccount
            .eraseError()
            .flatMap { account -> AnyPublisher<ReceiveAddress, Error> in
                account.receiveAddress
            }
            .map { [asset] receiveAddress in
                ResolutionRecord(symbol: asset.code, walletAddress: receiveAddress.address)
            }
            .eraseToAnyPublisher()
    }
}
