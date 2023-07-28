// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

#if canImport(BlockchainComponentLibrary)

import BlockchainComponentLibrary
import BlockchainNamespace

extension CurrencyType {
    public var logoResource: ImageResource {
        switch self {
        case .crypto(let currency):
            return currency.logoResource
        case .fiat(let currency):
            return currency.logoResource
        }
    }
}

extension FiatCurrency {
    public var logoResource: ImageResource {
        switch self {
        case .GBP:
            return .local(name: "fiat-gbp", bundle: .module)
        case .EUR:
            return .local(name: "fiat-eur", bundle: .module)
        case .USD:
            return .local(name: "fiat-usd", bundle: .module)
        default:
            return .local(name: "fiat-usd", bundle: .module)
        }
    }
}

extension CryptoCurrency {
    public var logoResource: ImageResource {
        switch self {
        case .bitcoin:
            return .local(name: "crypto-btc", bundle: .module)
        case .bitcoinCash:
            return .local(name: "crypto-bch", bundle: .module)
        case .ethereum:
            return .local(name: "crypto-eth", bundle: .module)
        case .stellar:
            return .local(name: "crypto-xlm", bundle: .module)
        default:
            return assetModelImageResource ?? placeholderImageResource
        }
    }

    private var assetModelImageResource: ImageResource? {
        assetModel.logoPngUrl.map(ImageResource.remote(url:))
    }

    private var placeholderImageResource: ImageResource {
        .systemName("squareshape.squareshape.dashed")
    }
}

#endif
