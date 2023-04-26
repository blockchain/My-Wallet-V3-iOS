// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DelegatedSelfCustodyDomain
import Errors
import FeatureDexDomain

extension DexMain {
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)

        case destinationAction(DexCell.Action)
        case sourceAction(DexCell.Action)

        case didTapSettings
        case onAppear
        case onBalances(Result<[DexBalance], UX.Error>)
        case onQuote(Result<DexQuoteOutput, UX.Error>)
        case refreshQuote
        case updateAvailableBalances([DexBalance])
        case updateQuote(DexQuoteOutput?)
    }
}
