// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
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
            VStack(spacing: Spacing.padding3) {
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color.semantic.background)
                            .frame(width: 88)
                        Image("icon-email-verification", bundle: .featureKYCUI)
                            .accessibility(identifier: "KYC.EmailVerification.verify.prompt.image")
                    }
                    ZStack {
                        Circle()
                            .fill(Color.semantic.light)
                            .frame(width: 58)
                        Circle()
                            .fill(Color.semantic.background)
                            .frame(width: 42)
                        Icon.questionCircle
                            .color(Color.semantic.muted)
                            .frame(width: 49)
                    }
                    .offset(x: Spacing.padding2, y: Spacing.padding2)
                }
                VStack(spacing: 0) {
                    Text(L10n.EmailVerificationHelp.title)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                        .padding(.bottom, Spacing.padding1)
                    Text(L10n.EmailVerificationHelp.message)
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                VStack(spacing: Spacing.padding2) {
                    PrimaryButton(
                        title: L10n.EmailVerificationHelp.sendEmailAgainButtonTitle,
                        isLoading: viewStore.sendingVerificationEmail
                    ) {
                        viewStore.send(.sendVerificationEmail)
                    }
                    PrimaryWhiteButton(title: L10n.EmailVerificationHelp.editEmailAddressButtonTitle) {
                        viewStore.send(.editEmailAddress)
                    }
                }
            }
            .padding(Spacing.padding2)
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
