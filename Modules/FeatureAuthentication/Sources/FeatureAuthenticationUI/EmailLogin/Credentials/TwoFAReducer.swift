// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationDomain
import WalletPayloadKit

// MARK: - Type

public enum TwoFAAction: Equatable {
    public enum IncorrectTwoFAContext: Equatable {
        case incorrect
        case missingCode
        case none

        var hasError: Bool {
            self != .none
        }
    }

    case didChangeTwoFACode(String)
    case didChangeTwoFACodeAttemptsLeft(Int)
    case showIncorrectTwoFACodeError(IncorrectTwoFAContext)
    case showResendSMSButton(Bool)
    case showTwoFACodeField(Bool)
}

private enum Constants {
    static let twoFACodeMaxAttemptsLeft = 5
}

// MARK: - Properties

struct TwoFAState: Equatable {
    var twoFACode: String
    var twoFAType: WalletAuthenticatorType
    var isTwoFACodeFieldVisible: Bool
    var isResendSMSButtonVisible: Bool
    var isTwoFACodeIncorrect: Bool
    var twoFACodeIncorrectContext: TwoFAAction.IncorrectTwoFAContext
    var twoFACodeAttemptsLeft: Int

    init(
        twoFACode: String = "",
        twoFAType: WalletAuthenticatorType = .standard,
        isTwoFACodeFieldVisible: Bool = false,
        isResendSMSButtonVisible: Bool = false,
        isTwoFACodeIncorrect: Bool = false,
        twoFACodeIncorrectContext: TwoFAAction.IncorrectTwoFAContext = .none,
        twoFACodeAttemptsLeft: Int = Constants.twoFACodeMaxAttemptsLeft
    ) {
        self.twoFACode = twoFACode
        self.twoFAType = twoFAType
        self.isTwoFACodeFieldVisible = isTwoFACodeFieldVisible
        self.isResendSMSButtonVisible = isResendSMSButtonVisible
        self.isTwoFACodeIncorrect = isTwoFACodeIncorrect
        self.twoFACodeIncorrectContext = twoFACodeIncorrectContext
        self.twoFACodeAttemptsLeft = twoFACodeAttemptsLeft
    }
}

let twoFAReducer = Reducer<
    TwoFAState,
    TwoFAAction,
    CredentialsEnvironment
> { state, action, _ in
    switch action {
    case .didChangeTwoFACode(let code):
        state.twoFACode = code
        return .none
    case .didChangeTwoFACodeAttemptsLeft(let attemptsLeft):
        state.twoFACodeAttemptsLeft = attemptsLeft
        return EffectTask(value: .showIncorrectTwoFACodeError(.incorrect))
    case .showIncorrectTwoFACodeError(let context):
        state.twoFACodeIncorrectContext = context
        state.isTwoFACodeIncorrect = context.hasError
        return .none
    case .showResendSMSButton(let shouldShow):
        state.isResendSMSButtonVisible = shouldShow
        return .none
    case .showTwoFACodeField(let isVisible):
        state.twoFACode = ""
        state.isTwoFACodeFieldVisible = isVisible
        return .none
    }
}
