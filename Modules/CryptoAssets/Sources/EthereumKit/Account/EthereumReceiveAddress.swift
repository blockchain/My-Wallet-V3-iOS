// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxSwift

struct EthereumReceiveAddress: CryptoReceiveAddress, QRCodeMetadataProvider {

    var asset: CryptoCurrency {
        eip681URI.cryptoCurrency
    }

    var address: String {
        eip681URI.method.destination ?? eip681URI.address
    }

    var qrCodeMetadata: QRCodeMetadata {
        QRCodeMetadata(content: address, title: address)
    }

    let label: String
    let onTxCompleted: TxCompleted
    let eip681URI: EIP681URI
    let assetName: String = ""

    init(
        eip681URI: EIP681URI,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) {
        self.eip681URI = eip681URI
        self.label = label
        self.onTxCompleted = onTxCompleted
    }

    init?(
        address: String,
        label: String,
        network: EVMNetwork,
        onTxCompleted: @escaping TxCompleted
    ) {
        guard let eip681URI = EIP681URI(address: address, network: network) else {
            return nil
        }
        self.eip681URI = eip681URI
        self.label = label
        self.onTxCompleted = onTxCompleted
    }
}
