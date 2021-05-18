//
//  CryptoCurrency+Conveniences.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/28/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import ToolKit

extension CryptoCurrency {

    /// Initialize with a display currency code: `BTC`, `ETH`, `BCH`, `XLM`, `USD-D`, `ALGO`, `USD-T`
    public init?(displayCode: String) {
        guard let currency = (CryptoCurrency.allCases.first { $0.displayCode == displayCode }) else {
            return nil
        }
        self = currency
    }

    // MARK: - UIColor

    public var brandColor: UIColor {
        switch self {
        case .aave:
            return .aave
        case .algorand:
            return .algorand
        case .bitcoin:
            return .bitcoin
        case .bitcoinCash:
            return .bitcoinCash
        case .ethereum:
            return .ethereum
        case .pax:
            return .usdd
        case .polkadot:
            return .polkadot
        case .stellar:
            return .stellar
        case .tether:
            return .tether
        case .wDGLD:
            return .black
        case .yearnFinance:
            return .yearnFinance
        }
    }

    /// Defaults to brand color with 15% opacity.
    public var accentColor: UIColor {
        switch self {
        case .wDGLD:
            return UIColor.wdgld.withAlphaComponent(0.15)
        case .aave,
             .algorand,
             .bitcoin,
             .bitcoinCash,
             .ethereum,
             .pax,
             .polkadot,
             .stellar,
             .tether,
             .yearnFinance:
            return brandColor.withAlphaComponent(0.15)
        }
    }

    // MARK: Filled small image

    /// Image file name for small logo.
    /// Note that the images are on PlatformUIKit Bundle.
    public var filledImageSmallName: String {
        switch self {
        case .aave:
            return "filled_aave_small"
        case .algorand:
            return "filled_algo_small"
        case .bitcoin:
            return "filled_btc_small"
        case .bitcoinCash:
            return "filled_bch_small"
        case .ethereum:
            return "filled_eth_small"
        case .pax:
            return "filled_pax_small"
        case .polkadot:
            return "filled_dot_small"
        case .stellar:
            return "filled_xlm_small"
        case .tether:
            return "filled_usdt_small"
        case .wDGLD:
            return "filled_wdgld_small"
        case .yearnFinance:
            return "filled_yfi_small"
        }
    }

    /// Image file name for large logo.
    /// Note that the images are on PlatformUIKit Bundle.
    public var logoImageName: String {
        switch self {
        case .aave:
            return "filled_aave_large"
        case .algorand:
            return "filled_algo_large"
        case .bitcoin:
            return "filled_btc_large"
        case .bitcoinCash:
            return "filled_bch_large"
        case .ethereum:
            return "filled_eth_large"
        case .pax:
            return "filled_pax_large"
        case .polkadot:
            return "filled_dot_large"
        case .stellar:
            return "filled_xlm_large"
        case .tether:
            return "filled_usdt_large"
        case .wDGLD:
            return "filled_wdgld_large"
        case .yearnFinance:
            return "filled_yfi_large"
        }
    }

    public var logo: UIImage {
        UIImage(named: logoImageName, in: .platformUIKit, compatibleWith: nil)!
    }

    public var filledImageSmall: UIImage {
        UIImage(named: filledImageSmallName, in: .platformUIKit, compatibleWith: nil)!
    }
}
