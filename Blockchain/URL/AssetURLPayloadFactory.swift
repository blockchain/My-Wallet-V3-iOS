//
//  AssetURLPayloadFactory.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import EthereumKit
import Foundation
import PlatformKit
import StellarKit
import ToolKit

final class AssetURLPayloadFactory: AssetURLPayloadFactoryAPI {

    func create(fromString string: String?, asset: CryptoCurrency) -> CryptoAssetQRMetadata? {
        guard let string = string else { return nil }
        if string.contains(":") {
            guard let url = URL(string: string) else {
                Logger.shared.warning("Could not create payload from URL \(string)")
                return nil
            }
            return create(from: url)
        } else {
            switch asset {
            case .bitcoin:
                return BitcoinURLPayload(address: string, amount: nil, paymentRequestUrl: nil)
            case .bitcoinCash:
                return BitcoinCashURLPayload(address: string, amount: nil, paymentRequestUrl: nil)
            case .stellar:
                return StellarURLPayload(address: string, amount: nil)
            case .pax, .ethereum:
                return EthereumURLPayload(address: string, amount: nil)
            case .aave,
                 .algorand,
                 .polkadot,
                 .tether,
                 .wDGLD,
                 .yearnFinance:
                return nil
            }
        }
    }

    func create(from url: URL) -> CryptoAssetQRMetadata? {
        guard let scheme = url.scheme else {
            Logger.shared.warning("Cannot create AssetURLPayload. Scheme is nil.")
            return nil
        }

        switch scheme {
        case BitcoinURLPayload.scheme:
            return BitcoinURLPayload(url: url)
        case BitcoinCashURLPayload.scheme:
            return BitcoinCashURLPayload(url: url)
        case StellarURLPayload.scheme:
            return StellarURLPayload(url: url)
        case EthereumURLPayload.scheme:
            return EthereumURLPayload(url: url)
        default:
            return nil
        }
    }
}
