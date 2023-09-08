// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import WalletCore

struct ReceiveAddressContext {
    let multiAddressContext: [AddressItem]
    let receiveIndex: UInt32
    let receiveAddress: String
}

func receiveAddressContext(
    for addresses: [AddressItem],
    coin: BitcoinChainCoin,
    context: AccountKeyContextProtocol
) -> ReceiveAddressContext {
    let receiveIndex: UInt32 = {
        let defaultAddress = addresses.first(where: {
            $0.xpub == context.defaultDerivation(coin: coin).xpub
        })
        guard let address = defaultAddress else {
            return 0
        }
        return UInt32(address.accountIndex)
    }()
    let receiveAddress = deriveReceiveAddress(
        context: context,
        coin: coin,
        receiveIndex: receiveIndex
    )
    return ReceiveAddressContext(
        multiAddressContext: addresses,
        receiveIndex: receiveIndex,
        receiveAddress: receiveAddress
    )
}

func deriveReceiveAddress(
    context: AccountKeyContextProtocol,
    coin: BitcoinChainCoin,
    receiveIndex: UInt32
) -> String {
    let privateKey = context.defaultDerivation(coin: coin)
        .receivePrivateKey(
            receiveIndex: receiveIndex
        )
    return coin.walletCoreCoinType.deriveAddress(privateKey: privateKey)
}
