// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

private typealias L10n = LocalizationConstants.NewKYC

struct EmailVerifiedState: Equatable {}

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

    var body: some View {
        WithViewStore(store) { viewStore in
            ActionableView(
                image: {
                    Image("email_verification_success", bundle: .featureKYCUI)
                        .accessibility(identifier: "KYC.EmailVerification.verified.prompt.image")
                },
                title: L10n.EmailVerified.title,
                message: L10n.EmailVerified.message,
                buttons: [
                    .init(
                        title: L10n.EmailVerified.continueButtonTitle,
                        action: {
                            viewStore.send(.acknowledgeEmailVerification)
                        }
                    )
                ],
                imageSpacing: 0
            )
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
                initialState: .init(),
                reducer: emailVerifiedReducer,
                environment: EmailVerifiedEnvironment()
            )
        )
        .preferredColorScheme(.light)

        EmailVerifiedView(
            store: .init(
                initialState: .init(),
                reducer: emailVerifiedReducer,
                environment: EmailVerifiedEnvironment()
            )
        )
        .preferredColorScheme(.dark)
    }
}
#endif
