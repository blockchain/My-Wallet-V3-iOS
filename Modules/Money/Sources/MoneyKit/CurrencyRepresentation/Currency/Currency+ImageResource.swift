// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

#if canImport(BlockchainComponentLibrary)

import BlockchainComponentLibrary
import BlockchainNamespace

extension CurrencyType {
    public var logoResource: ImageLocation {
        switch self {
        case .crypto(let currency):
            currency.logoResource
        case .fiat(let currency):
            currency.logoResource
        }
    }
}

extension FiatCurrency {
    public var logoResource: ImageLocation {
        switch self {
        case .GBP:
            .local(name: "fiat-gbp", bundle: .module)
        case .EUR:
            .local(name: "fiat-eur", bundle: .module)
        case .USD:
            .local(name: "fiat-usd", bundle: .module)
        default:
            .local(name: "fiat-usd", bundle: .module)
        }
    }
}

extension CryptoCurrency {
    public var logoResource: ImageLocation {
        if isInTest {
            return placeholder
        }
        return assetModelImageResource ?? placeholder
    }

    private var assetModelImageResource: ImageLocation? {
        assetModel.logoPngUrl.flatMap { .remote(url: $0, fallback: placeholder) }
    }

    private var placeholder: ImageLocation {
        placeholderImageLocation(displayCode)
    }
}

func placeholderImageLocation(_ value: String) -> ImageLocation {
    if let first = value.first?.lowercased(), first.isAlphanumeric {
        .systemName("\(first).circle.fill")
    } else {
        .systemName("circle.dashed")
    }
}

#endif
