// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Foundation
import MoneyKit

public struct SwapEnterAmountAnalytics: ReducerProtocol {
    var app: AppProtocol
    public typealias State = SwapEnterAmount.State
    public typealias Action = SwapEnterAmount.Action

    public init(app: AppProtocol) {
        self.app = app
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .onPreviewTapped:
                return .fireAndForget {
                    app.post(event: blockchain.ux.transaction.enter.amount.button.confirm.tap)
                }

            case .onMaxButtonTapped:
                return .fireAndForget {
                    app.post(event: blockchain.ux.transaction.enter.amount.button.max.tap)
                }

            case .onChangeInputTapped:
                let value = state.isEnteringFiat
                app.state.set(blockchain.ux.transaction.enter.amount.swap.input.crypto, to: value)
                app.state.set(blockchain.ux.transaction.enter.amount.swap.input.fiat, to: !value)
                return .none

            case .onSelectSourceTapped:
                return .fireAndForget {
                    app.post(event: blockchain.ux.transaction.enter.amount.button.change.source)
                }

            case .onSelectTargetTapped:
                return .fireAndForget {
                    app.post(event: blockchain.ux.transaction.enter.amount.button.change.target)
                }

            case .onSelectFromCryptoAccountAction(let action):
                switch action {
                case .accountRow(let id, let action):
                    guard action == .onAccountSelected else { return .none }
                    if let selectedAccountRow = state.selectFromCryptoAccountState?.swapAccountRows.filter({ $0.id == id }).first,
                       let currency = selectedAccountRow.currency
                    {
                        return .fireAndForget {
                            app.state.set(blockchain.ux.transaction.source.id, to: currency.code)
                            app.post(event: blockchain.ux.transaction.enter.amount.swap.source.selected)
                        }
                    }
                    return .none
                default:
                    return .none
                }

            case .onSelectToCryptoAccountAction(let action):
                switch action {
                case .onCloseTapped:
                    state.showAccountSelect.toggle()
                    return .none

                case .accountRow(_, .onAccountSelected(let accountId)):
                    return .run { [targetIsDefi = state.selectToCryptoAccountState?.filterDefiAccountsOnly ?? false] _ in
                        if let currency = try? await app.get(blockchain.coin.core.account[accountId].currency, as: CryptoCurrency.self) {
                            app.state.set(blockchain.ux.transaction.source.target.id, to: currency.code)
                            app.state.set(blockchain.ux.transaction.source.target.analytics.type, to: targetIsDefi ? "USERKEY" : "TRADING")
                            app.post(event: blockchain.ux.transaction.enter.amount.swap.target.selected)
                        }
                    }

                case .accountRow:
                    return .none

                default:
                    return .none
                }

            case .didFetchPairs(let source, let target):
                return .fireAndForget {
                    app.state.set(blockchain.ux.transaction.source.id, to: source.currency.code)
                    app.state.set(blockchain.ux.transaction.source.target.id, to: target.currency.code)
                }

            default:
                return .none
            }
        }
    }
}
