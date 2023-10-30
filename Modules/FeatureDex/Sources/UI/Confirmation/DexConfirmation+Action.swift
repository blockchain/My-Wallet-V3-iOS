// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

extension DexConfirmation {
    public enum Action: BindableAction, Equatable {
        case acceptPrice
        case confirm
        case binding(BindingAction<State>)
    }
}
