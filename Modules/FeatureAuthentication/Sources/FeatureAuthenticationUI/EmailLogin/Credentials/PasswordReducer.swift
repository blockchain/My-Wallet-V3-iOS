// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum PasswordAction: Equatable {
    case didChangePassword(String)
    case didChangeFocusedState(Bool)
    case showIncorrectPasswordError(Bool)
}

// MARK: - Properties

struct PasswordState: Equatable {
    var password: String
    var isFocused: Bool
    var isPasswordIncorrect: Bool

    var isValid: Bool {
        !isPasswordIncorrect && !password.isEmpty
    }

    init() {
        self.password = ""
        self.isFocused = false
        self.isPasswordIncorrect = false
    }
}

struct PasswordReducer: ReducerProtocol {
    typealias State = PasswordState
    typealias Action = PasswordAction

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didChangePassword(let password):
                state.isPasswordIncorrect = false
                state.password = password
                return .none
            case .didChangeFocusedState(let isFocused):
                state.isFocused = isFocused
                return .none
            case .showIncorrectPasswordError(let shouldShow):
                state.isPasswordIncorrect = shouldShow
                return .none
            }
        }
    }
}
