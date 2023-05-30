// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

extension DexConfirmation {
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case confirm
        case acceptPrice
    }
}
