// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

final class StellarAsset: CryptoAsset {

    // MARK: - Properties

    let asset: CryptoCurrency = .stellar

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        Just(())
            .receive(on: DispatchQueue.main)
            .flatMap { [accountRepository] _ -> AnyPublisher<StellarWalletAccount, CryptoAssetError> in
                accountRepository.initializeMetadataMaybe()
                    .mapError { _ in CryptoAssetError.noDefaultAccount }
                    .eraseToAnyPublisher()
            }
            .first()
            .map { account -> SingleAccount in
                StellarCryptoAccount(
                    publicKey: account.publicKey,
                    label: account.label,
                    hdAccountIndex: account.index
                )
            }
            .mapError(CryptoAssetError.failedToLoadDefaultAccount)
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
        defaultAccountProvider: { [defaultAccount] in
            defaultAccount
        },
        exchangeAccountsProvider: exchangeAccountProvider,
        addressFactory: addressFactory
    )

    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let accountRepository: StellarWalletAccountRepositoryAPI
    private let errorRecorder: ErrorRecording
    private let addressFactory: StellarCryptoReceiveAddressFactory
    private let kycTiersService: KYCTiersServiceAPI

    // MARK: - Setup

    init(
        accountRepository: StellarWalletAccountRepositoryAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        addressFactory: StellarCryptoReceiveAddressFactory = .init()
    ) {
        self.exchangeAccountProvider = exchangeAccountProvider
        self.accountRepository = accountRepository
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
        self.addressFactory = addressFactory
    }

    // MARK: - Public methods

    func initialize() -> AnyPublisher<Void, AssetError> {
        cryptoAssetRepository.nonCustodialGroup
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
