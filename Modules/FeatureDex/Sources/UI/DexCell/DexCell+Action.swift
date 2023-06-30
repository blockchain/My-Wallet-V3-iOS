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
        case assetPicker(AssetPicker.Action)
        case onCurrentNetworkChanged
        case onAvailableBalancesChanged
        case onPrice(FiatValue?)
    }
}
