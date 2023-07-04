// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

extension AssetPicker {

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onDismiss
        case binding(BindingAction<State>)
        case onAssetTapped(RowData)
        case didTapCloseInProgressCard
        case onPendingTransactionStatus(Bool)
    }
}
