//
//  QRCodeGenerator.swift
//  Blockchain
//
//  Created by Jack on 02/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import Foundation
import PlatformKit
import PlatformUIKit

@available(swift, deprecated: 1.0, message: "Use `QRCode: QRCodeAPI` and `CryptoAssetQRMetadata` instead")
@objc class QRCodeGenerator: NSObject {

    @objc override init() {
        super.init()
    }
    
    @objc func qrImage(fromAddress address: String, amount: String?, asset legacyAsset: LegacyAssetType, includeScheme: Bool) -> UIImage? {
        guard let metadata = metadata(address: address, amount: amount, asset: legacyAsset, includeScheme: includeScheme) else { return nil }
        return QRCode(metadata: metadata)?.image
    }
    
    @objc func createQRImage(fromString string: String) -> UIImage? {
        QRCode(string: string)?.image
    }
    
    private func metadata(address: String, amount: String?, asset legacyAsset: LegacyAssetType, includeScheme: Bool) -> CryptoAssetQRMetadata? {
        switch legacyAsset {
        case .bitcoin:
            return BitcoinURLPayload(
                address: address,
                amount: amount,
                includeScheme: includeScheme
            )
        case .bitcoinCash:
            return BitcoinCashURLPayload(
                address: address,
                amount: amount,
                includeScheme: includeScheme
            )
        case .aave,
             .algorand,
             .ether,
             .pax,
             .polkadot,
             .stellar,
             .tether,
             .WDGLD,
             .yearnFinance:
            return nil
        }
    }
}
