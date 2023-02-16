// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import MoneyKit
import PlatformKit
import RxSwift

struct ERC20ReceiveAddress: CryptoReceiveAddress, QRCodeMetadataProvider {

    var address: String {
        eip681URI.method.destination ?? eip681URI.address
    }

    var qrCodeMetadata: QRCodeMetadata {
        QRCodeMetadata(content: address, title: address)
    }

    let asset: CryptoCurrency
    let label: String
    let onTxCompleted: TxCompleted
    let eip681URI: EIP681URI

    var assetName: String {
        asset.name
    }

    init?(
        asset: CryptoCurrency,
        eip681URI: EIP681URI,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) {
        guard Self.validateCryptoCurrency(eip681URI: eip681URI, cryptoCurrency: asset) else {
            return nil
        }
        self.asset = asset
        self.eip681URI = eip681URI
        self.label = label
        self.onTxCompleted = onTxCompleted
    }

    init?(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        guard let eip681URI = EIP681URI(address: address, cryptoCurrency: asset, enabledCurrenciesService: enabledCurrenciesService) else {
            return nil
        }
        self.init(asset: asset, eip681URI: eip681URI, label: label, onTxCompleted: onTxCompleted)
    }

    /// When creating a ERC20ReceiveAddress, the EIP681URI must be for .ethereum or the specific CryptoCurrency required.
    private static func validateCryptoCurrency(
        eip681URI: EIP681URI,
        cryptoCurrency: CryptoCurrency
    ) -> Bool {
        eip681URI.cryptoCurrency == .ethereum
            || eip681URI.cryptoCurrency == cryptoCurrency
    }
}
