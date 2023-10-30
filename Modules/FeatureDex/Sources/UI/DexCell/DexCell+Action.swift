// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DelegatedSelfCustodyDomain
import FeatureDexDomain

extension DexCell {
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case preselectCurrency
        case didSelectCurrency(DexBalance)
        case onTapBalance
        case onTapCurrencySelector
        case onTapNetworkSelector
        case assetPicker(AssetPicker.Action)
        case networkPicker(NetworkPicker.Action)
        case onCurrentNetworkChanged(EVMNetwork?)
        case onAvailableBalancesChanged
        case onPrice(FiatValue?)
    }
}
