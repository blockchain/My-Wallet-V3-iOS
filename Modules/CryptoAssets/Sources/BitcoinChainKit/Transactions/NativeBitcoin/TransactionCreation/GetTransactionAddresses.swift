// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import WalletCore

struct TransactionAddresses {
    let changeAddress: String
    let receiveAddress: String
}

func getTransactionAddresses(
    context: NativeBitcoinTransactionContext
) -> TransactionAddresses {
    let accountKeyContext = context.accountKeyContext

    let receiveAddressContext = receiveAddressContext(
        for: context.multiAddressItems,
        coin: context.coin,
        context: context.accountKeyContext
    )

    let addresses = receiveAddressContext.multiAddressContext
    let receiveAddress = receiveAddressContext.receiveAddress
    let receiveIndex = receiveAddressContext.receiveIndex

    guard receiveIndex > 0 else {
        return TransactionAddresses(
            changeAddress: receiveAddress,
            receiveAddress: receiveAddress
        )
    }

    let changeIndex: UInt32 = {
        let defaultAddress = addresses.first(where: {
            $0.xpub == accountKeyContext.defaultDerivation(coin: context.coin).xpub
        })
        guard let address = defaultAddress else {
            return 0
        }
        return UInt32(address.changeIndex)
    }()

    let changeAddress = deriveChangeAddress(
        context: accountKeyContext,
        coin: context.coin,
        changeIndex: changeIndex
    )

    return TransactionAddresses(
        changeAddress: changeAddress,
        receiveAddress: receiveAddress
    )
}

private func deriveChangeAddress(
    context: AccountKeyContextProtocol,
    coin: BitcoinChainCoin,
    changeIndex: UInt32
) -> String {
    let privateKey = context.defaultDerivation(coin: coin)
        .changePrivateKey(
            changeIndex: changeIndex
        )
    return coin.walletCoreCoinType.deriveAddress(privateKey: privateKey)
}
