// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Localization

struct ButtonAction: Equatable {

    let title: String
    let icon: Icon
    let event: L
    var disabled: Bool

    mutating func set(disabled: Bool) {
        self.disabled = disabled
    }

    static func buy() -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.buy,
            icon: Icon.walletBuy,
            event: blockchain.ux.asset.buy,
            disabled: false
        )
    }

    static func send() -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.send,
            icon: Icon.walletSend,
            event: blockchain.ux.asset.send,
            disabled: false
        )
    }

    static func receive() -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.receive,
            icon: Icon.walletReceive,
            event: blockchain.ux.asset.receive,
            disabled: false
        )
    }

    static func sell() -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.sell,
            icon: Icon.walletSell,
            event: blockchain.ux.asset.sell,
            disabled: false
        )
    }

    static func swap() -> ButtonAction {
        return ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.swap,
            icon: Icon.walletSwap,
            event: blockchain.ux.asset.account.currency.exchange,
            disabled: false
        )
    }

    static func getToken(currency: String) -> ButtonAction {
        return ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.getToken.interpolating(currency),
            icon: Icon.walletSwap,
            event: blockchain.ux.asset.account.currency.get.token,
            disabled: false
        )
    }
}
