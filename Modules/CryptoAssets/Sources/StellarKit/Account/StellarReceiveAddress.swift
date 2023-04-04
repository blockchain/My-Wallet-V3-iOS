// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

struct StellarReceiveAddress: CryptoReceiveAddress, QRCodeMetadataProvider {

    let asset: CryptoCurrency = .stellar
    let address: String
    let label: String
    let memo: String?
    let onTxCompleted: TxCompleted

    var qrCodeMetadata: QRCodeMetadata {
        QRCodeMetadata(content: sep7URI.absoluteString, title: address)
    }

    var assetName: String {
        asset.name
    }

    private let sep7URI: SEP7URI

    init(
        address: String,
        label: String,
        memo: String? = nil,
        onTxCompleted: @escaping TxCompleted = { _ in .empty() }
    ) {
        self.address = address
        self.label = label
        self.memo = memo
        self.onTxCompleted = onTxCompleted
        self.sep7URI = SEP7URI(address: address, amount: nil, memo: memo)
    }
}
