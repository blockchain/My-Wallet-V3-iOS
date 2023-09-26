// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Errors
import Foundation
import MoneyKit
import ToolKit

public class AssetInformationService {

    let app: AppProtocol
    let cryptoCurrency: CryptoCurrency
    let repository: AssetInformationRepositoryAPI
    let currenciesService: EnabledCurrenciesServiceAPI

    public init(
        app: AppProtocol,
        cryptoCurrency: CryptoCurrency,
        repository: AssetInformationRepositoryAPI,
        currenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.app = app
        self.cryptoCurrency = cryptoCurrency
        self.repository = repository
        self.currenciesService = currenciesService
    }

    public func fetch() -> AnyPublisher<AboutAssetInformation, Never> {
        info.zip(marketCap)
            .map { [networkConfig, contractAddress] info, marketCap in
                AboutAssetInformation(
                    description: info?.description,
                    whitepaper: info?.whitepaper,
                    website: info?.website,
                    network: networkConfig?.name,
                    marketCap: marketCap,
                    contractAddress: contractAddress
                )
            }
            .eraseToAnyPublisher()
    }

    private var info: AnyPublisher<AssetInformation?, Never> {
        repository.fetchInfo(cryptoCurrency.code)
            .optional()
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private var marketCap: AnyPublisher<FiatValue?, Never> {
        app.publisher(
            for: blockchain.api.nabu.gateway.price.crypto[cryptoCurrency.code].fiat,
            as: blockchain.api.nabu.gateway.price.crypto.fiat
        )
        .map(\.value)
        .replaceError(with: nil)
        .map { info -> FiatValue? in
            guard let info else {
                return nil
            }
            guard let price = try? info.quote.value(FiatValue.self) else {
                return nil
            }
            guard let value: Double = info.market.cap else {
                return nil
            }
            return FiatValue.create(major: value, currency: price.currency)
        }
        .eraseToAnyPublisher()
    }

    private var networkConfig: EVMNetworkConfig? {
        currenciesService.network(for: cryptoCurrency)?.networkConfig
    }

    private var contractAddress: String? {
        cryptoCurrency.assetModel.kind.erc20ContractAddress
    }
}

// MARK: - Preview Helper

extension AssetInformationService {

    public static var preview: AssetInformationService {
        AssetInformationService(
            app: App.preview,
            cryptoCurrency: .bitcoin,
            repository: PreviewAssetInformationRepository(.just(.preview)),
            currenciesService: EnabledCurrenciesService.default
        )
    }

    public static var previewEmpty: AssetInformationService {
        AssetInformationService(
            app: App.preview,
            cryptoCurrency: .bitcoin,
            repository: PreviewAssetInformationRepository(),
            currenciesService: EnabledCurrenciesService.default
        )
    }
}
