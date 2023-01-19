// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift

public struct BitcoinChainReceiveAddress<Token: BitcoinChainToken>: CryptoReceiveAddress,
    QRCodeMetadataProvider
{

    public let address: String
    public let asset: CryptoCurrency
    public let bip21URI: BIP21URI<Token>
    public let label: String
    public let onTxCompleted: TxCompleted

    public var assetName: String {
        asset.name
    }

    public var qrCodeMetadata: QRCodeMetadata {
        QRCodeMetadata(content: bip21URI.absoluteString, title: address)
    }

    public init(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) {
        self.asset = Token.coin.cryptoCurrency
        self.bip21URI = BIP21URI<Token>(address: address, amount: nil, includeScheme: true)
        self.address = address
        self.label = label
        self.onTxCompleted = onTxCompleted
    }

    public init(
        bip21URI: BIP21URI<Token>,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) {
        self.asset = Token.coin.cryptoCurrency
        self.address = bip21URI.address
        self.bip21URI = bip21URI
        self.label = label
        self.onTxCompleted = onTxCompleted
    }
}
