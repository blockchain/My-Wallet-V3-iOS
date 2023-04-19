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

    static func buy(disabled: Bool = false) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.buy,
            icon: Icon.walletBuy,
            event: blockchain.ux.asset.buy,
            disabled: false
        )
    }

    static func send(disabled: Bool = false) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.send,
            icon: Icon.walletSend,
            event: blockchain.ux.asset.send,
            disabled: disabled
        )
    }

    static func receive(disabled: Bool = false) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.receive,
            icon: Icon.walletReceive,
            event: blockchain.ux.asset.receive,
            disabled: false
        )
    }

    static func sell(disabled: Bool = false) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.sell,
            icon: Icon.walletSell,
            event: blockchain.ux.asset.sell,
            disabled: disabled
        )
    }

    static func swap(disabled: Bool = false) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.swap,
            icon: Icon.walletSwap,
            event: blockchain.ux.asset.account.currency.exchange,
            disabled: disabled
        )
    }
}
