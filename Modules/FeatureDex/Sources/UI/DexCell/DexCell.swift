// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DelegatedSelfCustodyDomain
import FeatureDexDomain

public struct DexCell: Reducer {

    @Dependency(\.app) var app

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAvailableBalancesChanged:
                if let activeCurrency = state.balance?.currency,
                   let updatedBalance = state.availableBalances.first(where: { $0.currency == activeCurrency })
                {
                    state.balance = updatedBalance
                }
                return Effect.send(.preselectCurrency)
            case .onAppear:
                return Effect.send(.preselectCurrency)
            case .onTapBalance:
                if let balance = state.balance {
                    state.inputText = balance.value.toDisplayString(includeSymbol: false)
                }
                return .none
            case .onTapNetworkSelector:
                state.networkPicker = .init(currentNetwork: state.currentNetwork?.networkConfig.networkTicker)
                state.showNetworkPicker = true
                return .none
            case .onTapCurrencySelector:
                guard let currentNetwork = state.currentNetwork else {
                    return .none
                }
                state.assetPicker = AssetPicker.State(
                    balances: state.availableBalances,
                    tokens: state.supportedTokens,
                    denylist: state.bannedToken.flatMap { [$0] } ?? [],
                    currentNetwork: currentNetwork,
                    searchText: "",
                    isSearching: false
                )
                state.showAssetPicker = true
                return .none

            case .onCurrentNetworkChanged(let value):
                state.currentNetwork = value
                dexCellClear(state: &state)
                return .merge(
                    .cancel(id: CancellationID.price),
                    Effect.send(.preselectCurrency)
                )

            case .preselectCurrency:
                switch state.style {
                case .source:
                    guard getThatSourceCurrency(app: app).isNotNil || state.balance.isNil else {
                        return .none
                    }
                    guard let balance = favoriteSourceToken(app: app, state: state) else { return .none }
                    return Effect.send(.didSelectCurrency(balance))

                case .destination:
                    guard getThatDestinationCurrency(app: app).isNotNil || state.balance.isNil else {
                        return .none
                    }
                    guard let balance = favoriteDestinationToken(app: app, state: state) else { return .none }
                    return Effect.send(.didSelectCurrency(balance))
                }

            case .didSelectCurrency(let balance):
                if balance != state.balance {
                    dexCellClear(state: &state)
                }
                state.balance = balance
                let currencyCode = balance.currency.code

                return .publisher {
                    app
                        .publisher(
                            for: blockchain.api.nabu.gateway.price.crypto[currencyCode].fiat.quote.value,
                            as: FiatValue?.self
                        )
                        .replaceError(with: nil)
                        .receive(on: DispatchQueue.main)
                        .map(Action.onPrice)
                }
                .cancellable(id: CancellationID.price, cancelInFlight: true)

            case .onPrice(let price):
                state.price = price
                return .none

            case .networkPicker(.onDismiss):
                state.showNetworkPicker = false
                return .none
            case .networkPicker(.onNetworkSelected(let value)):
                state.showNetworkPicker = false
                return Effect.send(.onCurrentNetworkChanged(value))
            case .networkPicker:
                return .none

            case .assetPicker(.onDismiss):
                state.showAssetPicker = false
                return .none
            case .assetPicker(.onAssetTapped(let row)):
                state.showAssetPicker = false

                let balance: DexBalance = row.content.balance
                return .merge(
                    .cancel(id: CancellationID.price),
                    Effect.send(.didSelectCurrency(balance))
                )
            case .assetPicker:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.assetPicker, action: /Action.assetPicker) {
            AssetPicker()
        }
        .ifLet(\.networkPicker, action: /Action.networkPicker) {
            NetworkPicker()
        }
    }
}

func dexCellClear(state: inout DexCell.State) {
    state.balance = nil
    state.price = nil
    state.inputText = ""
    state.overrideAmount = nil
}

private func favoriteSourceToken(
    app: AppProtocol,
    state: DexCell.State
) -> DexBalance? {
    guard let network = state.currentNetwork else {
        return nil
    }

    if let preselected = getThatSourceCurrency(app: app),
       let preselectedBalance = state.filteredBalances.first(where: { $0.currency == preselected })
    {
        eraseThatCurrency(app: app)
        return preselectedBalance
    }

    guard let first = state.filteredBalances.first else {
        return .zero(network.nativeAsset)
    }
    let nativeBalance = state.filteredBalances
        .first(where: { $0.currency == network.nativeAsset })
    return nativeBalance ?? first
}

private func favoriteDestinationToken(
    app: AppProtocol,
    state: DexCell.State
) -> DexBalance? {
    guard let network = state.currentNetwork else {
        return nil
    }

    if let preselected = getThatDestinationCurrency(app: app),
       preselected.network() == network
    {
        let preselectedBalance = state.filteredBalances
            .first(where: { $0.currency == preselected }) ?? .zero(preselected)
        eraseThatCurrency(app: app)
        return preselectedBalance
    }

    return nil
}

extension DexCell {
    enum CancellationID {
        case price
    }
}
