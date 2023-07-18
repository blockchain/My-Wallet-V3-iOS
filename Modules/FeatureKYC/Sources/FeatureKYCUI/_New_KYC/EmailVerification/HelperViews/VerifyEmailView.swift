// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

private typealias L10n = LocalizationConstants.NewKYC

struct VerifyEmailState: Equatable {

    var emailAddress: String
    var cannotOpenMailAppAlert: AlertState<VerifyEmailAction>?

    init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
}

enum VerifyEmailAction: Equatable {
    case tapCheckInbox
    case tapGetEmailNotReceivedHelp
    case presentCannotOpenMailAppAlert
    case dismissCannotOpenMailAppAlert
}

struct VerifyEmailEnvironment {
    var openMailApp: () -> EffectTask<Bool>
}

let verifyEmailReducer = Reducer<
    VerifyEmailState,
    VerifyEmailAction,
    VerifyEmailEnvironment
> { state, action, environment in
    switch action {
    case .tapCheckInbox:
        return environment.openMailApp()
            .map { didSucceed in
                didSucceed ? .dismissCannotOpenMailAppAlert : .presentCannotOpenMailAppAlert
            }

    case .tapGetEmailNotReceivedHelp:
        return .none

    case .presentCannotOpenMailAppAlert:
        // NOTE: this should happen only on Simulators
        state.cannotOpenMailAppAlert = AlertState(title: .init("Cannot Open Mail App"))
        return .none

    case .dismissCannotOpenMailAppAlert:
        state.cannotOpenMailAppAlert = nil
        return .none
    }
}

struct VerifyEmailView: View {

    let store: Store<VerifyEmailState, VerifyEmailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.semantic.background)
                        .frame(width: 88)
                    Image("icon-email-verification", bundle: .featureKYCUI)
                        .renderingMode(.template)
                        .colorMultiply(.semantic.title)
                        .accessibility(identifier: "KYC.EmailVerification.verify.prompt.image")
                }
                VStack(spacing: 0) {
                    Text(L10n.VerifyEmail.title)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                        .padding(.bottom, Spacing.padding1)
                    Text(L10n.VerifyEmail.message)
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                        .multilineTextAlignment(.center)
                    Text(viewStore.state.emailAddress)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                        .multilineTextAlignment(.center)
                }
                TagView(text: L10n.VerifyEmail.notVerified, variant: .warning)
                Spacer()
                VStack(spacing: Spacing.padding2) {
                    PrimaryButton(title: L10n.VerifyEmail.checkInboxButtonTitle) {
                        viewStore.send(.tapCheckInbox)
                    }
                    PrimaryWhiteButton(title: L10n.VerifyEmail.getHelpButtonTitle) {
                        viewStore.send(.tapGetEmailNotReceivedHelp)
                    }
                }
            }
            .padding(Spacing.padding2)
            .alert(store.scope(state: \.cannotOpenMailAppAlert), dismiss: .dismissCannotOpenMailAppAlert)
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .accessibility(identifier: "KYC.EmailVerification.verify.container")
    }
}

#if DEBUG
struct VerifyEmailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerifyEmailView(
                store: .init(
                    initialState: .init(
                        emailAddress: "test@example.com"
                    ),
                    reducer: verifyEmailReducer,
                    environment: VerifyEmailEnvironment(
                        openMailApp: { EffectTask(value: true) }
                    )
                )
            )
            .preferredColorScheme(.light)

            VerifyEmailView(
                store: .init(
                    initialState: .init(
                        emailAddress: "test@example.com"
                    ),
                    reducer: verifyEmailReducer,
                    environment: VerifyEmailEnvironment(
                        openMailApp: { EffectTask(value: true) }
                    )
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
#endif
