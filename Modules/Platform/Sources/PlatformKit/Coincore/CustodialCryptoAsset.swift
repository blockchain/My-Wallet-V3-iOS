// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import RxSwift
import ToolKit

final class CustodialCryptoAsset: CryptoAsset {

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        .failure(.noDefaultAccount)
    }

    let asset: CryptoCurrency

    var canTransactToCustodial: AnyPublisher<Bool, Never> { .just(true) }

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

    private let kycTiersService: KYCTiersServiceAPI
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let addressFactory: ExternalAssetAddressFactory

    // MARK: - Setup

    init(
        asset: CryptoCurrency,
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve()
    ) {
        self.asset = asset
        self.kycTiersService = kycTiersService
        self.exchangeAccountProvider = exchangeAccountProvider
        self.errorRecorder = errorRecorder
        addressFactory = PlainCryptoReceiveAddressFactory(asset: asset)
    }

    // MARK: - Asset

    func initialize() -> AnyPublisher<Void, AssetError> {
        Just(())
            .mapError(to: AssetError.self)
            .eraseToAnyPublisher()
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup, Never> {
        switch filter {
        case .all:
            return allAccountsGroup
        case .custodial:
            return custodialGroup
        case .interest:
            return interestGroup
        case .nonCustodial:
            return nonCustodialGroup
        case .exchange:
            return exchangeGroup
        }
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        addressFactory
            .makeExternalAssetAddress(
                address: address,
                label: address,
                onTxCompleted: { _ in .empty() }
            )
            .publisher
            .map { address -> ReceiveAddress? in
                address
            }
            .catch { _ -> AnyPublisher<ReceiveAddress?, Never> in
                .just(nil)
            }
            .eraseToAnyPublisher()
    }

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        addressFactory.makeExternalAssetAddress(
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        )
    }

    private var allAccountsGroup: AnyPublisher<AccountGroup, Never> {
        [
            nonCustodialGroup,
            custodialGroup,
            interestGroup,
            exchangeGroup
        ]
        .zip()
        .eraseToAnyPublisher()
        .flatMapAllAccountGroup()
    }

    private var exchangeGroup: AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.exchangeGroup
    }

    private var custodialGroup: AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.custodialGroup
    }

    private var nonCustodialGroup: AnyPublisher<AccountGroup, Never> {
        .just(
            CryptoAccountNonCustodialGroup(
                asset: asset,
                accounts: []
            )
        )
    }

    private var interestGroup: AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.interestGroup
    }
}
