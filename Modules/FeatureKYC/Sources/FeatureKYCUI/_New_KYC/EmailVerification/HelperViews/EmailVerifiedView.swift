// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

private typealias L10n = LocalizationConstants.NewKYC

struct EmailVerifiedState: Equatable {
    var emailAddress: String

    init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
}

enum EmailVerifiedAction: Equatable {
    case acknowledgeEmailVerification
}

struct EmailVerifiedEnvironment: Equatable {}

typealias EmailVerifiedReducer = Reducer<EmailVerifiedState, EmailVerifiedAction, EmailVerifiedEnvironment>

let emailVerifiedReducer = EmailVerifiedReducer { _, _, _ in
    .none
}

struct EmailVerifiedView: View {

    let store: Store<EmailVerifiedState, EmailVerifiedAction>

    var confetti: ConfettiConfiguration {
        ConfettiConfiguration(
            confetti: [
                .view(Circle().frame(width: 10.pt).foregroundColor(.semantic.success)),
                .view(Rectangle().frame(width: 8.pt, height: 8.pt).foregroundColor(.semantic.primary)),
                .view(Triangle().frame(width: 11.pt, height: 11.pt).foregroundColor(.semantic.pink))
            ]
        )
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ConfettiCannonView(confetti) { action in
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
                            Image("email-checked", bundle: .featureKYCUI)
                        }
                        .offset(x: Spacing.padding2, y: Spacing.padding2)
                    }
                    VStack(spacing: 0) {
                        Text(L10n.EmailVerified.title)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)
                            .padding(.bottom, Spacing.padding1)
                        Text(L10n.EmailVerified.message)
                            .typography(.body1)
                            .foregroundColor(.semantic.body)
                            .multilineTextAlignment(.center)
                        Text(viewStore.state.emailAddress)
                            .typography(.body2)
                            .foregroundColor(.semantic.title)
                            .multilineTextAlignment(.center)
                    }
                    TagView(text: L10n.EmailVerified.verified, variant: .success)
                    Spacer()
                    PrimaryButton(title: L10n.EmailVerified.continueButtonTitle) {
                        viewStore.send(.acknowledgeEmailVerification)
                    }
                }
                .padding(Spacing.padding2)
                .onAppear {
                    action()
                }
            }
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .accessibility(identifier: "KYC.EmailVerification.verified.container")
    }
}

#if DEBUG
struct EmailVerifiedView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerifiedView(
            store: .init(
                initialState: .init(
                    emailAddress: "test@example.com"
                ),
                reducer: emailVerifiedReducer,
                environment: EmailVerifiedEnvironment()
            )
        )
        .preferredColorScheme(.light)

        EmailVerifiedView(
            store: .init(
                initialState: .init(
                    emailAddress: "test@example.com"
                ),
                reducer: emailVerifiedReducer,
                environment: EmailVerifiedEnvironment()
            )
        )
        .preferredColorScheme(.dark)
    }
}
#endif
