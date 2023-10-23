// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

private typealias L10n = LocalizationConstants.NewKYC

struct VerifyEmailState: Equatable {

    var emailAddress: String
    @PresentationState var cannotOpenMailAppAlert: AlertState<VerifyEmailAction.AlertAction>?

    init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
}

enum VerifyEmailAction: Equatable {
    enum AlertAction {
        case dismiss
        case present
    }

    case tapCheckInbox
    case tapGetEmailNotReceivedHelp
    case alert(PresentationAction<AlertAction>)
}

struct VerifyEmailReducer: Reducer {

    typealias State = VerifyEmailState
    typealias Action = VerifyEmailAction

    var openMailApp: () async -> Bool

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tapCheckInbox:
                return .run { [openMailApp] send in
                    if await openMailApp() {
                        await send(.alert(.presented(.dismiss)))
                        return
                    }
                    await send(.alert(.presented(.present)))
                }

            case .tapGetEmailNotReceivedHelp:
                return .none

            case .alert(.presented(.present)):
                // NOTE: this should happen only on Simulators
                state.cannotOpenMailAppAlert = AlertState(title: .init("Cannot Open Mail App"))
                return .none

            case .alert(.presented(.dismiss)), .alert(.dismiss):
                state.cannotOpenMailAppAlert = nil
                return .none
            }
        }
    }
}

struct VerifyEmailView: View {

    let store: Store<VerifyEmailState, VerifyEmailAction>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
            .alert(
                store: store.scope(
                    state: \.$cannotOpenMailAppAlert,
                    action: { .alert($0) }
                )
            )
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
                store: Store(
                    initialState: .init(
                        emailAddress: "test@example.com"
                    ),
                    reducer: {
                        VerifyEmailReducer { false }
                    }
                )
            )
            .preferredColorScheme(.light)

            VerifyEmailView(
                store: Store(
                    initialState: .init(
                        emailAddress: "test@example.com"
                    ),
                    reducer: {
                        VerifyEmailReducer { true }
                    }
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
#endif
