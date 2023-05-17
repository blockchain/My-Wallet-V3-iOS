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
    var saveEmailFailureAlert: AlertState<EditEmailAction>?

    init(emailAddress: String) {
        self.emailAddress = emailAddress
        self.isEmailValid = emailAddress.isEmail
    }
}

enum EditEmailAction: Equatable {
    case didAppear
    case didChangeEmailAddress(String)
    case didReceiveSaveResponse(Result<Int, UpdateEmailAddressError>)
    case dismissSaveEmailFailureAlert
    case save
}

struct EditEmailEnvironment {
    let emailVerificationService: EmailVerificationServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validateEmail: (String) -> Bool = { $0.isEmail }
}

let editEmailReducer = Reducer<EditEmailState, EditEmailAction, EditEmailEnvironment> { state, action, environment in
    switch action {
    case .didAppear:
        state.isEmailValid = environment.validateEmail(state.emailAddress)
        return .none

    case .didChangeEmailAddress(let emailAddress):
        state.emailAddress = emailAddress
        state.isEmailValid = environment.validateEmail(emailAddress)
        return .none

    case .save:
        guard state.isEmailValid else {
            return .none
        }
        state.savingEmailAddress = true
        return environment.emailVerificationService.updateEmailAddress(to: state.emailAddress)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                switch result {
                case .success:
                    return .didReceiveSaveResponse(.success(0))
                case .failure(let error):
                    return .didReceiveSaveResponse(.failure(error))
                }
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

    case .dismissSaveEmailFailureAlert:
        state.saveEmailFailureAlert = nil
        return .none
    }
}

struct EditEmailView: View {

    let store: Store<EditEmailState, EditEmailAction>

    @State private var isEmailFieldFirstResponder: Bool = true

    var body: some View {
        WithViewStore(store) { viewStore in
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
                                configuration: {
                                    $0.textContentType = .emailAddress
                                    $0.returnKeyType = .done
                                },
                                onReturnTapped: {
                                    isEmailFieldFirstResponder = false
                                }
                            )
                            .accessibility(identifier: "KYC.EmailVerification.edit.email.group")

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
                store.scope(state: \.saveEmailFailureAlert),
                dismiss: .dismissSaveEmailFailureAlert
            )
            .onAppear {
                viewStore.send(.didAppear)
            }
        }
        .background(Color.semantic.light)
        .accessibility(identifier: "KYC.EmailVerification.edit.container")
    }
}

#if DEBUG
struct EditEmailView_Previews: PreviewProvider {
    static var previews: some View {
        // Invalid state: empty email
        EditEmailView(
            store: .init(
                initialState: .init(emailAddress: ""),
                reducer: editEmailReducer,
                environment: EditEmailEnvironment(
                    emailVerificationService: NoOpEmailVerificationService(),
                    mainQueue: .main
                )
            )
        )

        // Invalid state: invalid email typed by user
        EditEmailView(
            store: .init(
                initialState: .init(emailAddress: "invalid.com"),
                reducer: editEmailReducer,
                environment: EditEmailEnvironment(
                    emailVerificationService: NoOpEmailVerificationService(),
                    mainQueue: .main
                )
            )
        )

        // Valid state
        EditEmailView(
            store: .init(
                initialState: .init(emailAddress: "test@example.com"),
                reducer: editEmailReducer,
                environment: EditEmailEnvironment(
                    emailVerificationService: NoOpEmailVerificationService(),
                    mainQueue: .main
                )
            )
        )

        // Loading state
        EditEmailView(
            store: .init(
                initialState: {
                    var state = EditEmailState(emailAddress: "test@example.com")
                    state.savingEmailAddress = true
                    return state
                }(),
                reducer: editEmailReducer,
                environment: EditEmailEnvironment(
                    emailVerificationService: NoOpEmailVerificationService(),
                    mainQueue: .main
                )
            )
        )
    }
}
#endif
