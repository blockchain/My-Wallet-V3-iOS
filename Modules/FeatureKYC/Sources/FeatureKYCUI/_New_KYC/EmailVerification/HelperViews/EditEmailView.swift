// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import FeatureKYCDomain
import Localization
import SwiftUI
import UIComponentsKit

private typealias L10n = LocalizationConstants.NewKYC

struct EditEmailState: Equatable {
    var emailAddress: String
    var isEmailValid: Bool
    var savingEmailAddress: Bool = false
    @PresentationState var saveEmailFailureAlert: AlertState<EditEmailAction.AlertAction>?

    init(emailAddress: String) {
        self.emailAddress = emailAddress
        self.isEmailValid = emailAddress.isEmail
    }
}

enum EditEmailAction: Equatable {
    enum AlertAction {
        case dismiss
        case save
    }

    case didAppear
    case didChangeEmailAddress(String)
    case didReceiveSaveResponse(Result<Int, UpdateEmailAddressError>)
    case alert(PresentationAction<AlertAction>)
    case save
}

struct EditEmailReducer: Reducer {
    
    typealias State = EditEmailState
    typealias Action = EditEmailAction

    let emailVerificationService: EmailVerificationServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validateEmail: (String) -> Bool = { $0.isEmail }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                state.isEmailValid = validateEmail(state.emailAddress)
                return .none

            case .didChangeEmailAddress(let emailAddress):
                state.emailAddress = emailAddress
                state.isEmailValid = validateEmail(emailAddress)
                return .none

            case .save, .alert(.presented(.save)):
                guard state.isEmailValid else {
                    return .none
                }
                state.savingEmailAddress = true
                return .publisher { [emailAddress = state.emailAddress] in
                    emailVerificationService.updateEmailAddress(to: emailAddress)
                        .receive(on: mainQueue)
                        .map { .didReceiveSaveResponse(.success(0)) }
                        .catch { .didReceiveSaveResponse(.failure($0)) }
                }

            case .didReceiveSaveResponse(let response):
                state.savingEmailAddress = false
                switch response {
                case .success:
                    return .none

                case .failure:
                    state.saveEmailFailureAlert = AlertState(
                        title: TextState(L10n.GenericError.title),
                        message: TextState(L10n.EditEmail.couldNotUpdateEmailAlertMessage),
                        primaryButton: .default(
                            TextState(L10n.GenericError.retryButtonTitle),
                            action: .send(.save)
                        ),
                        secondaryButton: .cancel(
                            TextState(L10n.GenericError.cancelButtonTitle)
                        )
                    )
                    return .none
                }

            case .alert(.dismiss), .alert(.presented(.dismiss)):
                state.saveEmailFailureAlert = nil
                return .none
            }
        }
    }
}

struct EditEmailView: View {

    let store: Store<EditEmailState, EditEmailAction>

    @State private var isEmailFieldFirstResponder: Bool = true

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ActionableView(
                buttons: [
                    .init(
                        title: L10n.EditEmail.saveButtonTitle,
                        action: {
                            viewStore.send(.save)
                        },
                        loading: viewStore.savingEmailAddress,
                        enabled: viewStore.isEmailValid
                    )
                ],
                content: {
                    VStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(L10n.EditEmail.title)
                                .typography(.title3)
                                .foregroundColor(.semantic.title)
                            Text(L10n.EditEmail.message)
                                .typography(.body1)
                                .foregroundColor(.semantic.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        VStack(spacing: LayoutConstants.VerticalSpacing.betweenContentGroups) {
                            Input(
                                text: viewStore.binding(
                                    get: { $0.emailAddress },
                                    send: { .didChangeEmailAddress($0) }
                                ),
                                isFirstResponder: $isEmailFieldFirstResponder,
                                label: L10n.EditEmail.editEmailFieldLabel,
                                state: .default,
                                onReturnTapped: {
                                    isEmailFieldFirstResponder = false
                                }
                            )
                            .accessibility(identifier: "KYC.EmailVerification.edit.email.group")
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .submitLabel(.done)

                            if !viewStore.isEmailValid {
                                BadgeView(
                                    title: L10n.EditEmail.invalidEmailInputMessage,
                                    style: .error
                                )
                                .accessibility(identifier: "KYC.EmailVerification.edit.email.invalidEmail")
                            }
                        }

                        Spacer()
                    }
                }
            )
            .alert(
                store: store.scope(
                    state: \.$saveEmailFailureAlert,
                    action: { .alert($0) }
                )
            )
            .onAppear {
                viewStore.send(.didAppear)
            }
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .accessibility(identifier: "KYC.EmailVerification.edit.container")
    }
}

#if DEBUG
struct EditEmailView_Previews: PreviewProvider {
    static var previews: some View {
        // Invalid state: empty email
        EditEmailView(
            store: Store(
                initialState: .init(emailAddress: ""),
                reducer: {
                    EditEmailReducer(
                        emailVerificationService: NoOpEmailVerificationService(),
                        mainQueue: .main
                    )
                }
            )
        )

        // Invalid state: invalid email typed by user
        EditEmailView(
            store: Store(
                initialState: .init(emailAddress: "invalid.com"),
                reducer: {
                    EditEmailReducer(
                        emailVerificationService: NoOpEmailVerificationService(),
                        mainQueue: .main
                    )
                }
            )
        )

        // Valid state
        EditEmailView(
            store: Store(
                initialState: .init(emailAddress: "test@example.com"),
                reducer: {
                    EditEmailReducer(
                        emailVerificationService: NoOpEmailVerificationService(),
                        mainQueue: .main
                    )
                }
            )
        )

        // Loading state
        EditEmailView(
            store: Store(
                initialState: {
                    var state = EditEmailState(emailAddress: "test@example.com")
                    state.savingEmailAddress = true
                    return state
                }(),
                reducer: {
                    EditEmailReducer(
                        emailVerificationService: NoOpEmailVerificationService(),
                        mainQueue: .main
                    )
                }
            )
        )
    }
}
#endif
