import ComposableArchitecture
import ComposableNavigation
import FeatureUserDeletionDomain
import Localization
import SwiftUI

private typealias LocalizedString = LocalizationConstants.UserDeletion.ConfirmationScreen

public enum FormField {
    case confirmation
}

public struct DeletionConfirmState: Equatable, NavigationState {
    public var route: RouteIntent<UserDeletionResultRoute>?

    @BindingState public var textFieldText: String = ""
    @BindingState public var firstResponder: FormField?

    public var isLoading: Bool = false
    public var isConfirmationInputValid: Bool = false
    public var shouldShowInvalidInputUI: Bool = false
    public var resultViewState: DeletionResultState?

    mutating func validateConfirmationInputField() {
        // handle isConfirmationInputValid
        isConfirmationInputValid = textFieldText ==
            LocalizedString.textField.placeholder

        // handle shouldShowInvalidInputUI
        let placeholder = LocalizedString.textField.placeholder
        let userIsTyping = firstResponder == .confirmation
        guard userIsTyping else {
            shouldShowInvalidInputUI = !isConfirmationInputValid
            return
        }
        let textSoFar = placeholder.prefix(textFieldText.count)
        shouldShowInvalidInputUI = textSoFar != textFieldText
    }

    public init(
        route: RouteIntent<UserDeletionResultRoute>? = nil
    ) {
        self.route = route
    }

    public static func == (
        lhs: DeletionConfirmState,
        rhs: DeletionConfirmState
    ) -> Bool {
        lhs.isLoading == rhs.isLoading &&
            lhs.route == rhs.route &&
            lhs.textFieldText == rhs.textFieldText &&
            lhs.firstResponder == rhs.firstResponder &&
            lhs.isConfirmationInputValid && rhs.isConfirmationInputValid &&
            lhs.shouldShowInvalidInputUI && rhs.shouldShowInvalidInputUI
    }
}

public enum UserDeletionResultRoute: NavigationRoute, Hashable {
    case showResultScreen

    @ViewBuilder
    public func destination(in store: Store<DeletionConfirmState, DeletionConfirmAction>) -> some View {
        switch self {
        case .showResultScreen:
            IfLetStore(
                store.scope(
                    state: \.resultViewState,
                    action: DeletionConfirmAction.onConfirmViewChanged
                ),
                then: { store in
                    DeletionResultView(store: store)
                }
            )
        }
    }
}
