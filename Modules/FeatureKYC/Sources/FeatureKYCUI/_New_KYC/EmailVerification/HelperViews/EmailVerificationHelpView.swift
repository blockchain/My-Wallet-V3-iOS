// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureKYCDomain
import Localization
import SwiftUI
import UIComponentsKit

struct EmailVerificationHelpState: Equatable {
    var emailAddress: String
    var sendingVerificationEmail: Bool = false
    var sentFailedAlert: AlertState<EmailVerificationHelpAction>?

    init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
}

enum EmailVerificationHelpAction: Equatable {
    case editEmailAddress
    case sendVerificationEmail
    case didReceiveEmailSendingResponse(Result<Int, UpdateEmailAddressError>)
    case dismissEmailSendingFailureAlert
}

struct EmailVerificationHelpEnvironment {
    let emailVerificationService: EmailVerificationServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

private typealias L10n = LocalizationConstants.NewKYC

typealias EmailVerificationHelpReducer = Reducer<
    EmailVerificationHelpState,
    EmailVerificationHelpAction,
    EmailVerificationHelpEnvironment
>

let emailVerificationHelpReducer = EmailVerificationHelpReducer { state, action, environment in
    switch action {
    case .editEmailAddress:
        return .none

    case .sendVerificationEmail:
        state.sendingVerificationEmail = true
        return environment.emailVerificationService.sendVerificationEmail(to: state.emailAddress)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                switch result {
                case .success:
                    return .didReceiveEmailSendingResponse(.success(0))
                case .failure(let error):
                    return .didReceiveEmailSendingResponse(.failure(error))
                }
            }

    case .didReceiveEmailSendingResponse(let result):
        state.sendingVerificationEmail = false
        switch result {
        case .success:
            return .none

        case .failure:
            state.sentFailedAlert = AlertState(
                title: TextState(L10n.GenericError.title),
                message: TextState(L10n.EmailVerificationHelp.couldNotSendEmailAlertMessage),
                primaryButton: .default(
                    TextState(L10n.GenericError.retryButtonTitle),
                    action: .send(.sendVerificationEmail)
                ),
                secondaryButton: .cancel(TextState(L10n.GenericError.cancelButtonTitle))
            )
            return .none
        }

    case .dismissEmailSendingFailureAlert:
        state.sentFailedAlert = nil
        return .none
    }
}

struct EmailVerificationHelpView: View {

    let store: Store<EmailVerificationHelpState, EmailVerificationHelpAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ActionableView(
                image: {
                    Image("email_verification_help", bundle: .featureKYCUI)
                        .accessibility(identifier: "KYC.EmailVerification.help.prompt.image")
                },
                title: L10n.EmailVerificationHelp.title,
                message: L10n.EmailVerificationHelp.message,
                buttons: [
                    .init(
                        title: L10n.EmailVerificationHelp.sendEmailAgainButtonTitle,
                        action: {
                            viewStore.send(.sendVerificationEmail)
                        },
                        loading: viewStore.sendingVerificationEmail
                    ),
                    .init(
                        title: L10n.EmailVerificationHelp.editEmailAddressButtonTitle,
                        action: {
                            viewStore.send(.editEmailAddress)
                        }
                    )
                ],
                imageSpacing: 0
            )
            .alert(
                store.scope(state: \.sentFailedAlert),
                dismiss: .dismissEmailSendingFailureAlert
            )
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .accessibility(identifier: "KYC.EmailVerification.help.container")
    }
}

#if DEBUG
struct EmailVerificationHelpView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationHelpView(
            store: .init(
                initialState: .init(emailAddress: "test@example.com"),
                reducer: emailVerificationHelpReducer,
                environment: EmailVerificationHelpEnvironment(
                    emailVerificationService: NoOpEmailVerificationService(),
                    mainQueue: .main
                )
            )
        )
        .preferredColorScheme(.light)

        EmailVerificationHelpView(
            store: .init(
                initialState: .init(emailAddress: "test@example.com"),
                reducer: emailVerificationHelpReducer,
                environment: EmailVerificationHelpEnvironment(
                    emailVerificationService: NoOpEmailVerificationService(),
                    mainQueue: .main
                )
            )
        )
        .preferredColorScheme(.dark)
    }
}
#endif
