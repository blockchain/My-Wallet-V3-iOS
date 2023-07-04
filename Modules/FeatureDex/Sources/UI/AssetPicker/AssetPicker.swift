// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public struct AssetPicker: ReducerProtocol {

    @Dependency(\.dexService) var dexService
    @Dependency(\.mainQueue) var mainQueue

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$searchText):
                state.searchResults = state.allData.filtered(by: state.searchText)
                return .none
            case .onAppear:
                return dexService.pendingActivity(state.currentNetwork)
                    .receive(on: mainQueue)
                    .eraseToEffect(Action.onPendingTransactionStatus)
                    .cancellable(id: CancellationID.pendingActivity, cancelInFlight: true)
            case .onDismiss:
                return .none
            case .onAssetTapped:
                return .none
            case .binding:
                return .none
            case .didTapCloseInProgressCard:
                state.networkTransactionInProgressCard = false
                return .none
            case .onPendingTransactionStatus(let value):
                state.networkTransactionInProgressCard = value
                return .none
            }
        }
    }
}

extension AssetPicker {
    enum CancellationID {
        case pendingActivity
    }
}
