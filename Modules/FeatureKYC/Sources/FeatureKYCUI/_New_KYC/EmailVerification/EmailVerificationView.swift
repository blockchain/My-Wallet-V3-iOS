// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI
import UIComponentsKit

/// Entry point to the Email Verification flow
struct EmailVerificationView: View {

    let store: Store<EmailVerificationState, EmailVerificationAction>
    @ObservedObject private(set) var viewStore: ViewStore<EmailVerificationState, EmailVerificationAction>

    init(store: Store<EmailVerificationState, EmailVerificationAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        PrimaryNavigationView {
            VStack {
                // Programmatic Navigation Stack
                // `EmptyView`s are set as source to hide the links since individual EV subviews don't know about destinations
                NavigationLink(
                    destination: EmailVerificationHelpRoutingView(
                        canShowEditAddressView: viewStore.flowStep == .editEmailAddress,
                        store: store
                    ),
                    isActive: .constant(
                        viewStore.flowStep == .emailVerificationHelp ||
                            viewStore.flowStep == .editEmailAddress
                    ),
                    label: EmptyView.init
                )

                // Root View when loading Email Verification Status
                if viewStore.flowStep == .loadingVerificationState || viewStore.flowStep == .verificationCheckFailed {
                    ActivityIndicatorView()
                        .accessibility(identifier: "KYC.EmailVerification.loading.spinner")
                        .alert(
                            store.scope(state: \.emailVerificationFailedAlert),
                            dismiss: .dismissEmailVerificationFailedAlert
                        )
                } else if viewStore.flowStep == .emailVerifiedPrompt {
                    // Final step of the flow
                    EmailVerifiedView(
                        store: store.scope(
                            state: \.emailVerified,
                            action: EmailVerificationAction.emailVerified
                        )
                    )
                    .removeNavigationBarItems()
                } else {
                    // Default Root View
                    VerifyEmailView(
                        store: store.scope(
                            state: \.verifyEmail,
                            action: EmailVerificationAction.verifyEmail
                        )
                    )
                    .navigationBarTitle("", displayMode: .inline)
                    .lightNavigationBarStyle()
                    .trailingNavigationButton(.close) {
                        viewStore.send(.closeButtonTapped)
                    }
                }
            }
            .onAppear {
                viewStore.send(.didAppear)
            }
            .onDisappear {
                viewStore.send(.didDisappear)
            }
            .onAppEnteredForeground {
                viewStore.send(.didEnterForeground)
            }
            .background(Color.semantic.light)
            .accessibility(identifier: "KYC.EmailVerification.container")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(Color.semantic.light.ignoresSafeArea())
    }
}

struct EmailVerificationHelpRoutingView: View {

    let canShowEditAddressView: Bool
    let store: Store<EmailVerificationState, EmailVerificationAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationLink(
                destination: (
                    EditEmailView(
                        store: store.scope(
                            state: \.editEmailAddress,
                            action: EmailVerificationAction.editEmailAddress
                        )
                    )
                    .navigationBarBackButtonHidden(true)
                    .trailingNavigationButton(.close) {
                        viewStore.send(.closeButtonTapped)
                    }
                ),
                isActive: .constant(canShowEditAddressView),
                label: EmptyView.init
            )
            EmailVerificationHelpView(
                store: store.scope(
                    state: \.emailVerificationHelp,
                    action: EmailVerificationAction.emailVerificationHelp
                )
            )
            .navigationBarBackButtonHidden(true)
            .trailingNavigationButton(.close) {
                viewStore.send(.closeButtonTapped)
            }
        }
    }
}

#if DEBUG
import AnalyticsKit

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView(
            store: .init(
                initialState: .init(emailAddress: "test@example.com"),
                reducer: emailVerificationReducer,
                environment: EmailVerificationEnvironment(
                    analyticsRecorder: NoOpAnalyticsRecorder(),
                    emailVerificationService: NoOpEmailVerificationService(),
                    flowCompletionCallback: nil,
                    openMailApp: { EffectTask(value: true) }
                )
            )
        )
    }
}
#endif
