// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

/// A `CryptoReceiveAddress & QRCodeMetadataProvider` that doesn't know how to validate the asset/address and assumes it is correct.
struct PlainCryptoReceiveAddress: CryptoReceiveAddress, QRCodeMetadataProvider {
    let address: String
    let asset: CryptoCurrency
    let label: String
    let assetName: String
    let memo: String?
    let accountType: AccountType = .external

    var qrCodeMetadata: QRCodeMetadata {
        QRCodeMetadata(content: address, title: address)
    }

    init(address: String, memo: String?, asset: CryptoCurrency, label: String) {
        self.address = address
        self.memo = memo
        self.asset = asset
        self.assetName = asset.name
        self.label = label
    }
}
