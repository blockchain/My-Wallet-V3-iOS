// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DelegatedSelfCustodyDomain
import FeatureDexDomain

public struct DexCell: ReducerProtocol {

    @Dependency(\.app) var app

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$inputText):
                return .none
            case .onAvailableBalancesChanged:
                if let activeCurrency = state.balance?.currency,
                   let updatedBalance = state.availableBalances.first(where: { $0.currency == activeCurrency }) {
                    state.balance = updatedBalance
                }
                return EffectTask(value: .preselectCurrency)
            case .onAppear:
                return EffectTask(value: .preselectCurrency)
            case .onTapBalance:
                if let balance = state.balance {
                    state.inputText = balance.value.toDisplayString(includeSymbol: false)
                }
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

            case .onCurrentNetworkChanged:
                dexCellClear(state: &state)
                return .merge(
                    .cancel(id: CancellationID.price),
                    EffectTask(value: .preselectCurrency)
                )

            case .preselectCurrency:
                guard state.style.isSource else { return .none }
                guard state.balance == nil else { return .none }
                guard let balance = favoriteToken(state: state) else { return .none }
                return .merge(
                    .cancel(id: CancellationID.price),
                    EffectTask(value: .didSelectCurrency(balance))
                )

            case .didSelectCurrency(let balance):
                if balance != state.balance {
                    dexCellClear(state: &state)
                }
                state.balance = balance
                let currencyCode = balance.currency.code

                return app
                    .publisher(
                        for: blockchain.api.nabu.gateway.price.crypto[currencyCode].fiat.quote.value,
                        as: FiatValue?.self
                    )
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect(Action.onPrice)
                    .cancellable(id: CancellationID.price, cancelInFlight: true)

            case .onPrice(let price):
                state.price = price
                return .none
            case .assetPicker(.onDismiss):
                state.showAssetPicker = false
                state.assetPicker = nil
                return .none

            case .assetPicker(.onAssetTapped(let row)):
                state.showAssetPicker = false

                let dexBalance: DexBalance = {
                    switch row.content {
                    case .balance(let dexBalance):
                        return dexBalance
                    case .token(let cryptoCurrency):
                        return DexBalance(value: .zero(currency: cryptoCurrency))
                    }
                }()
                return .merge(
                    .cancel(id: CancellationID.price),
                    EffectTask(value: .didSelectCurrency(dexBalance))
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
    }
}

func dexCellClear(state: inout DexCell.State) {
    state.balance = nil
    state.price = nil
    state.inputText = ""
    state.overrideAmount = nil
}

private func favoriteToken(state: DexCell.State) -> DexBalance? {
    guard let network = state.currentNetwork else { return nil }
    let zeroNative = DexBalance(value: .zero(currency: network.nativeAsset))
    guard let first = state.filteredBalances.first else { return zeroNative }
    let native = state.filteredBalances.first(where: { $0.currency == network.nativeAsset })
    return native ?? first
}

extension DexCell {
    enum CancellationID {
        case price
    }
}
