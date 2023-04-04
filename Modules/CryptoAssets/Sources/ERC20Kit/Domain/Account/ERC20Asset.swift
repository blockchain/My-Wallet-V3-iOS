// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20Asset: CryptoAsset {

    // MARK: - Properties

    let asset: CryptoCurrency

    var canTransactToCustodial: AnyPublisher<Bool, Never> {
        cryptoAssetRepository.canTransactToCustodial
    }

    // MARK: - Private properties

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        walletAccountRepository.defaultAccount(erc20Token: erc20Token, network: network)
    }

    // MARK: - Private properties

    private lazy var cryptoAssetRepository: CryptoAssetRepositoryAPI = CryptoAssetRepository(
        asset: asset,
        errorRecorder: errorRecorder,
        kycTiersService: kycTiersService,
        nonCustodialAccountsProvider: { [walletAccountRepository, erc20Token, network] in
            walletAccountRepository
                .defaultAccount(erc20Token: erc20Token, network: network)
                .map { [$0] }
                .eraseToAnyPublisher()
        },
        exchangeAccountsProvider: exchangeAccountProvider,
        addressFactory: addressFactory,
        featureFlag: featureFlag
    )

    let addressFactory: ExternalAssetAddressFactory

    private let erc20Token: AssetModel
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let network: EVMNetwork
    private let walletAccountRepository: EthereumWalletAccountRepositoryAPI
    private let featureFlag: FeatureFetching

    // MARK: - Setup

    init(
        erc20Token: AssetModel,
        network: EVMNetwork,
        walletAccountRepository: EthereumWalletAccountRepositoryAPI,
        errorRecorder: ErrorRecording,
        exchangeAccountProvider: ExchangeAccountsProviderAPI,
        kycTiersService: KYCTiersServiceAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        featureFlag: FeatureFetching
    ) {
        self.asset = erc20Token.cryptoCurrency!
        self.addressFactory = ERC20ExternalAssetAddressFactory(
            asset: asset,
            network: network,
            enabledCurrenciesService: enabledCurrenciesService
        )
        self.network = network
        self.erc20Token = erc20Token
        self.walletAccountRepository = walletAccountRepository
        self.errorRecorder = errorRecorder
        self.exchangeAccountProvider = exchangeAccountProvider
        self.kycTiersService = kycTiersService
        self.featureFlag = featureFlag
    }

    // MARK: - Asset

    func initialize() -> AnyPublisher<Void, AssetError> {
        .just(())
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

extension EthereumWalletAccountRepositoryAPI {

    fileprivate func defaultAccount(erc20Token: AssetModel, network: EVMNetwork) -> AnyPublisher<SingleAccount, CryptoAssetError> {
        defaultAccount
            .mapError(CryptoAssetError.failedToLoadDefaultAccount)
            .map { account in
                ERC20CryptoAccount(
                    publicKey: account.publicKey,
                    erc20Token: erc20Token,
                    network: network
                )
            }
            .eraseToAnyPublisher()
    }
}
