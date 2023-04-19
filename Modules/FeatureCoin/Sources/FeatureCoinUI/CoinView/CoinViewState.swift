// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureCoinDomain
import MoneyKit
import SwiftUI

public enum CoinViewError: Error, Equatable {
    case failedToLoad
}

public struct CoinViewState: Equatable {
    public let currency: CryptoCurrency
    public var accounts: [Account.Snapshot]
    public var recurringBuys: [RecurringBuy]?
    public var error: CoinViewError?
    public var assetInformation: AssetInformation?
    public var isRecurringBuyEnabled: Bool
    public var earnRates: EarnRates?
    public var kycStatus: KYCStatus?
    public var isFavorite: Bool?
    public var graph: GraphViewState

    var appMode: AppMode?

    /// Recurring buy should only be shown when the `AppMode` is `.trading` or `.universal`.
    var shouldShowRecurringBuy: Bool {
        guard let appMode else { return false }
        return appMode.isRecurringBuyViewSupported && isRecurringBuyEnabled
    }

    var swapButton: ButtonAction? {
        guard appMode != .universal else {
            return nil
        }
        let swapDisabled = !accounts.hasPositiveBalanceForSelling
        let swapAction = ButtonAction.swap(disabled: swapDisabled)
        let action = action(swapAction, whenAccountCan: .swap)
        return action
    }

    @BindingState public var recurringBuy: RecurringBuy?
    @BindingState public var account: Account.Snapshot?
    @BindingState public var explainer: Account.Snapshot?

    var allActions: [ButtonAction] {
        appMode == .pkw ? allDeFiModeCoinActions() : allTradingModeCoinActions()
    }

    var primaryActions: [ButtonAction] {
        appMode == .pkw ? primaryDefiModeCoinActions() : primaryTradingModeCoinActions()
    }

    private func allTradingModeCoinActions() -> [ButtonAction] {
        guard accounts.isNotEmpty else {
            return []
        }

        let actionsDisabled = kycStatus?.canSellCrypto == false || !accounts.hasPositiveBalanceForSelling
        if actionsDisabled == false {
            let receive = ButtonAction.receive(disabled: false)
            let send = ButtonAction.send(disabled: false)
            let swap = ButtonAction.swap()
            return [swap, receive, send]
        }
        return []
    }

    private func allDeFiModeCoinActions() -> [ButtonAction] {
        guard accounts.isNotEmpty else {
            return []
        }
        let send = ButtonAction.send()
        let receive = ButtonAction.receive()
        return [send, receive]
    }

    private func primaryTradingModeCoinActions() -> [ButtonAction] {
        if !currency.isTradable && !accounts.hasPositiveBalanceForSelling {
            return []
        }

        let sell = ButtonAction.sell()
        let buy = ButtonAction.buy()
        let receive = ButtonAction.receive()
        let sellingDisabled = kycStatus?.canSellCrypto == false || !accounts.hasPositiveBalanceForSelling

        return [sellingDisabled ? receive : sell, buy]
    }

    private func primaryDefiModeCoinActions() -> [ButtonAction] {
        let swap = ButtonAction.swap()
        let receive = ButtonAction.receive()

        return accounts.hasPositiveBalanceForSelling && accounts.canSwap ? [swap] : [receive]
    }

    private func action(_ action: ButtonAction, whenAccountCan accountAction: Account.Action) -> ButtonAction? {
        accounts.contains(where: { account in account.actions.contains(accountAction) }) ? action : nil
    }

    public init(
        currency: CryptoCurrency,
        kycStatus: KYCStatus? = nil,
        accounts: [Account.Snapshot] = [],
        recurringBuys: [RecurringBuy]? = nil,
        isRecurringBuyEnabled: Bool = false,
        assetInformation: AssetInformation? = nil,
        earnRates: EarnRates? = nil,
        error: CoinViewError? = nil,
        isFavorite: Bool? = nil,
        graph: GraphViewState = GraphViewState()
    ) {
        self.currency = currency
        self.kycStatus = kycStatus
        self.accounts = accounts
        self.assetInformation = assetInformation
        self.earnRates = earnRates
        self.error = error
        self.isFavorite = isFavorite
        self.graph = graph
        self.recurringBuys = recurringBuys
        self.isRecurringBuyEnabled = isRecurringBuyEnabled
    }
}

extension CryptoCurrency {

    var isTradable: Bool {
        supports(product: .custodialWalletBalance) || supports(product: .privateKey)
    }
}

extension AppMode {
    var isRecurringBuyViewSupported: Bool {
        switch self {
        case .universal,
                .trading:
            return true
        case .pkw:
            return false
        }
    }
}
