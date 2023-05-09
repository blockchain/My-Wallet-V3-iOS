// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Foundation

public struct SwapToAccountRow: ReducerProtocol {
    public let app: AppProtocol
    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onAccountSelected(String)
        case onCryptoCurrencyTapped
        case onDisplayAccountSelect([String])
        case onSelectAccountAction(SwapSelectAccount.Action)
        case binding(BindingAction<SwapToAccountRow.State>)
    }

    public struct State: Equatable, Identifiable {
        public var id: String {
            currency.code
        }

        var currency: CryptoCurrency
        var isLastRow: Bool
        var isCustodial: Bool
        var swapSelectAccountState: SwapSelectAccount.State?
        @BindingState var price: MoneyValue?
        @BindingState var delta: Decimal?
        @BindingState var showAccountSelect: Bool = false

        var leadingTitle: String {
            currency.name
        }

        var trailingTitle: String {
            price?.toDisplayString(includeSymbol: true) ?? ""
        }

        var trailingDescriptionString: String? {
            priceChangeString
        }

        var trailingDescriptionColor: Color? {
            priceChangeColor
        }

        public init(
            isLastRow: Bool,
            currency: CryptoCurrency,
            isCustodial: Bool
        ) {
            self.isLastRow = isLastRow
            self.currency = currency
            self.isCustodial = isCustodial
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$price):
                return .none
            case .binding:
                return .none

            case .onAppear:
                return .none

            case .onCryptoCurrencyTapped:
                return .run { [currency = state.currency.code, isCustodial = state.isCustodial] send in
                    if isCustodial {
                        let account = try await app.get(blockchain.coin.core.accounts.custodial.asset[currency], as: String.self)
                        await send(.onAccountSelected(account))
                    } else {
                        let accounts = try await app.get(blockchain.coin.core.accounts.DeFi.asset[currency], as: [String].self)
                        if accounts.count == 1, let account = accounts.first {
                            await send(.onAccountSelected(account))
                        } else {
                            await send(.onDisplayAccountSelect(accounts))
                        }
                    }
                }

            case .onDisplayAccountSelect(let accountIds):
                state.swapSelectAccountState = SwapSelectAccount.State(
                    accountIds: accountIds,
                    currency: state.currency
                )
                state.showAccountSelect.toggle()
                return .none

            case .onSelectAccountAction(let action):
                switch action {

                case .onCloseTapped:
                    state.showAccountSelect.toggle()
                    return .none

                case .onAccountSelected(let accountId):
                    return EffectTask(value: .onAccountSelected(accountId))

                case .accountRow(let id, let action) where action == .onAccountTapped:
                    return EffectTask(value: .onAccountSelected(id))

                case .accountRow:
                    return .none
                }

            case .onAccountSelected:
                return .none
            }
        }
        .ifLet(\.swapSelectAccountState, action: /Action.onSelectAccountAction, then: {
            SwapSelectAccount(app: app)
        })
    }
}

extension SwapToAccountRow.State {
    var priceChangeString: String? {
        guard let delta else {
            return nil
        }
        var arrowString: String {
            if delta.isZero {
                return ""
            }
            if delta.isSignMinus {
                return "↓"
            }

            return "↑"
        }
        if #available(iOS 15, *) {
            // delta value comes in range of 0...100, percent formatter needs to be in 0...1
            let deltaFormatted = delta.formatted(.percent.precision(.fractionLength(2)))
            return "\(arrowString) \(deltaFormatted)"
        } else {
            return "\(arrowString) \(delta) %"
        }
    }

    var priceChangeColor: Color? {
        guard let delta else {
            return nil
        }
        if delta.isZero {
            return Color.WalletSemantic.muted
        }
        return delta.isSignMinus ? Color.WalletSemantic.pinkHighlight : Color.WalletSemantic.success
    }

    //    var networkTag: TagView? {
    //        guard let networkName, networkName != currency?.name, appMode == .pkw else {
    //            return nil
    //        }
    //        return TagView(text: networkName, variant: .outline)
    //    }
}
