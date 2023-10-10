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
    @PresentationState var sentFailedAlert: AlertState<EmailVerificationHelpAction.AlertAction>?

    init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
}

enum EmailVerificationHelpAction: Equatable {
    enum AlertAction {
        case dismiss
        case sendVerificationEmail
    }
    case editEmailAddress
    case didReceiveEmailSendingResponse(Result<Int, UpdateEmailAddressError>)
    case alert(PresentationAction<AlertAction>)
}

private typealias L10n = LocalizationConstants.NewKYC

struct EmailVerificationHelpReducer: Reducer {
    
    typealias State = EmailVerificationHelpState
    typealias Action = EmailVerificationHelpAction

    let emailVerificationService: EmailVerificationServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .editEmailAddress:
                return .none

            case .alert(.presented(.sendVerificationEmail)):
                state.sendingVerificationEmail = true
                return .run { [state] send in
                    do {
                        try await emailVerificationService.sendVerificationEmail(to: state.emailAddress)
                            .receive(on: mainQueue)
                            .await()
                        await send(.didReceiveEmailSendingResponse(.success(0)))
                    } catch {
                        guard let error = error as? UpdateEmailAddressError else {
                            return
                        }
                        await send(.didReceiveEmailSendingResponse(.failure(error)))
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

            case .alert(.presented(.dismiss)), .alert(.dismiss):
                state.sentFailedAlert = nil
                return .none
            }
        }
    }
}

struct EmailVerificationHelpView: View {

    let store: Store<EmailVerificationHelpState, EmailVerificationHelpAction>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                        Icon.questionFilled
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
                        viewStore.send(.alert(.presented(.sendVerificationEmail)))
                    }
                    PrimaryWhiteButton(title: L10n.EmailVerificationHelp.editEmailAddressButtonTitle) {
                        viewStore.send(.editEmailAddress)
                    }
                }
            }
            .padding(Spacing.padding2)
            .alert(
                store: store.scope(
                    state: \.$sentFailedAlert,
                    action: { .alert($0) }
                )
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
            store: Store(
                initialState: .init(emailAddress: "test@example.com"),
                reducer: {
                    EmailVerificationHelpReducer(
                        emailVerificationService: NoOpEmailVerificationService(),
                        mainQueue: .main
                    )
                }
            )
        )
        .preferredColorScheme(.light)

        EmailVerificationHelpView(
            store: Store(
                initialState: .init(emailAddress: "test@example.com"),
                reducer: {
                    EmailVerificationHelpReducer(
                        emailVerificationService: NoOpEmailVerificationService(),
                        mainQueue: .main
                    )
                }
            )
        )
        .preferredColorScheme(.dark)
    }
}
#endif
