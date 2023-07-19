// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit

extension AssetModel {

    // MARK: - UIColor

    public var brandColor: Color {
        Color(brandUIColor)
    }

    /// The brand color.
    public var brandUIColor: UIColor {
        switch kind {
        case .coin:
            if let match = CustodialCoinCode.allCases.first(where: { $0.rawValue == code }) {
                return UIColor(hex: match.spotColor) ?? .black
            }
            return spotUIColor ?? .black
        case .erc20:
            return spotUIColor
                ?? UIColor(hex: ERC20Code.spotColor(code: code))!
        case .celoToken:
            return spotUIColor ?? .black
        case .fiat:
            return .fiat
        }
    }

    /// Defaults to brand color with 15% opacity.
    public var accentColor: UIColor {
        brandUIColor.withAlphaComponent(0.15)
    }

    // MARK: - Logo Image `ImageResource`

    public var logoResource: ImageResource {
        switch kind {
        case .coin:
            switch code {
            case NonCustodialCoinCode.bitcoin.rawValue:
                return .local(name: "crypto-btc", bundle: .platformUIKit)
            case NonCustodialCoinCode.bitcoinCash.rawValue:
                return .local(name: "crypto-bch", bundle: .platformUIKit)
            case NonCustodialCoinCode.ethereum.rawValue:
                return .local(name: "crypto-eth", bundle: .platformUIKit)
            case NonCustodialCoinCode.stellar.rawValue:
                return .local(name: "crypto-xlm", bundle: .platformUIKit)
            default:
                return logoPngResource ?? placeholderImageResource
            }
        case .erc20:
            return logoPngResource ?? placeholderImageResource
        case .celoToken:
            return logoPngResource ?? placeholderImageResource
        case .fiat:
            switch code {
            case FiatCurrency.GBP.rawValue:
                return .local(name: "icon-gbp", bundle: .platformUIKit)
            case FiatCurrency.EUR.rawValue:
                return .local(name: "icon-eur", bundle: .platformUIKit)
            case FiatCurrency.USD.rawValue:
                return .local(name: "icon-usd", bundle: .platformUIKit)
            case FiatCurrency.ARS.rawValue, FiatCurrency.BRL.rawValue:
                return .local(name: "icon-usd", bundle: .platformUIKit)
            default:
                return placeholderImageResource
            }
        }
    }

    private var placeholderImageResource: ImageResource {
        .local(name: "crypto-placeholder", bundle: .platformUIKit)
    }

    private var logoPngResource: ImageResource? {
        logoPngUrl.map(ImageResource.remote(url:))
    }

    private var spotUIColor: UIColor? {
        spotColor.flatMap(UIColor.init(hex:))
    }
}
