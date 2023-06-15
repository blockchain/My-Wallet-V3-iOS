// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DelegatedSelfCustodyDomain
import Errors
import FeatureDexDomain
import MoneyKit

extension DexMain {
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)

        case destinationAction(DexCell.Action)
        case sourceAction(DexCell.Action)
        case networkSelectionAction(NetworkPicker.Action)
        case confirmationAction(DexConfirmation.Action)

        case onAppear
        case didTapSettings
        case didTapPreview
        case didTapAllowance
        case didTapCloseInProgressCard

        case refreshAllowance
        case onAllowance(Result<DexAllowanceResult, UX.Error>)
        case updateAllowance(DexAllowanceResult?)

        case onSupportedTokens(Result<[CryptoCurrency], UX.Error>)
        case onAvailableChainsFetched(Result<[EVMNetwork], UX.Error>)
        case onBalances(Result<[DexBalance], UX.Error>)
        case updateAvailableBalances([DexBalance])

        case refreshQuote
        case onQuote(Result<DexQuoteOutput, UX.Error>?)
        case onSelectNetworkTapped
        case onTransaction(Result<String, UX.Error>, DexQuoteOutput)

        case onPendingTransactionStatus(Bool)
    }
}
