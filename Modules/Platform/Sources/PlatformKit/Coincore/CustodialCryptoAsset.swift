// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import DIKit
import MoneyKit
import ToolKit

final class CustodialCryptoAsset: CryptoAsset, CustomStringConvertible {

    var description: String {
        "CustodialCryptoAsset." + asset.code
    }

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        cryptoDelegatedCustodyAccount
            .map { $0 as SingleAccount? }
            .setFailureType(to: CryptoAssetError.self)
            .onNil(CryptoAssetError.noDefaultAccount)
            .eraseToAnyPublisher()
    }

    let asset: CryptoCurrency

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
        addressFactory: addressFactory
    )

    let addressFactory: ExternalAssetAddressFactory

    private let kycTiersService: KYCTiersServiceAPI
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let delegatedCustodyAccountRepository: DelegatedCustodyAccountRepositoryAPI

    // MARK: - Setup

    init(
        asset: CryptoCurrency,
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        delegatedCustodyAccountRepository: DelegatedCustodyAccountRepositoryAPI = resolve(),
        addressFactoryProvider: (_ asset: CryptoCurrency) -> ExternalAssetAddressFactory = externalAddressProvider(asset:)
    ) {
        self.asset = asset
        self.kycTiersService = kycTiersService
        self.exchangeAccountProvider = exchangeAccountProvider
        self.errorRecorder = errorRecorder
        self.delegatedCustodyAccountRepository = delegatedCustodyAccountRepository
        self.addressFactory = addressFactoryProvider(asset)
    }

    // MARK: - Asset

    func initialize() -> AnyPublisher<Void, AssetError> {
        Just(())
            .mapError(to: AssetError.self)
            .eraseToAnyPublisher()
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {
        cryptoAssetRepository.accountGroup(filter: filter)
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        addressFactory
            .makeExternalAssetAddress(
                address: address,
                label: address,
                onTxCompleted: { _ in AnyPublisher.just(()) }
            )
            .publisher
            .map { address -> ReceiveAddress? in
                address
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> AnyPublisher<Void, Error>
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        addressFactory.makeExternalAssetAddress(
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        )
    }

    private var cryptoDelegatedCustodyAccount: AnyPublisher<CryptoDelegatedCustodyAccount?, Never> {
        delegatedCustodyAccount
            .map { [addressFactory] delegatedCustodyAccount -> CryptoDelegatedCustodyAccount? in
                guard let delegatedCustodyAccount else {
                    return nil
                }
                return CryptoDelegatedCustodyAccount(
                    app: resolve(),
                    addressesRepository: resolve(),
                    addressFactory: addressFactory,
                    balanceRepository: resolve(),
                    priceService: resolve(),
                    delegatedCustodyAccount: delegatedCustodyAccount
                )
            }
            .eraseToAnyPublisher()
    }

    private var delegatedCustodyAccount: AnyPublisher<DelegatedCustodyAccount?, Never> {
        delegatedCustodyAccountRepository
            .delegatedCustodyAccounts
            .map { [asset] accounts in
                accounts.first(where: { $0.coin == asset })
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}

func externalAddressProvider(asset: CryptoCurrency) -> ExternalAssetAddressFactory {
    switch asset {
    case .bitcoin:
        return DIKit.resolve(tag: AddressFactoryTag.bitcoin)
    case .bitcoinCash:
        return DIKit.resolve(tag: AddressFactoryTag.bitcoinCash)
    case .stellar:
        return DIKit.resolve(tag: AddressFactoryTag.stellar)
    default:
        return PlainCryptoReceiveAddressFactory(asset: asset)
    }
}
