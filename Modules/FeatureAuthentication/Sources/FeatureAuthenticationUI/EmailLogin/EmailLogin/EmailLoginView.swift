// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public enum EmailLoginRoute: NavigationRoute {
    case verifyDevice

    @ViewBuilder
    public func destination(
        in store: Store<EmailLoginState, EmailLoginAction>
    ) -> some View {
        switch self {
        case .verifyDevice:
            IfLetStore(
                store.scope(
                    state: \.verifyDeviceState,
                    action: EmailLoginAction.verifyDevice
                ),
                then: VerifyDeviceView.init(store:)
            )
        }
    }
}

public struct EmailLoginView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.EmailLogin

    private let store: Store<EmailLoginState, EmailLoginAction>

    @State private var isEmailFieldFirstResponder: Bool = false

    public init(store: Store<EmailLoginState, EmailLoginAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                emailField
                Spacer()
                PrimaryButton(
                    title: LocalizedString.Button._continue,
                    isLoading: viewStore.isLoading
                ) {
                    viewStore.send(.continueButtonTapped)
                }
                .disabled(!viewStore.isEmailValid)
                .accessibility(identifier: AccessibilityIdentifiers.EmailLoginScreen.continueButton)
            }
            .padding(Spacing.padding3)
            .primaryNavigation(title: LocalizedString.navigationTitle) {
                Button {
                    viewStore.send(.continueButtonTapped)
                } label: {
                    Text(LocalizedString.Button.next)
                        .typography(.paragraph2)
                        .foregroundColor(
                            !viewStore.isEmailValid ? .semantic.muted : .semantic.primary
                        )
                }
                .disabled(!viewStore.isEmailValid)
                .accessibility(identifier: AccessibilityIdentifiers.EmailLoginScreen.nextButton)
            }
            .navigationRoute(in: store)
            .alert(store.scope(state: \.alert), dismiss: .alert(.dismiss))
            .onAppear {
                viewStore.send(.onAppear)
            }
            .background(Color.semantic.light.ignoresSafeArea())
        }
    }

    private var emailField: some View {
        WithViewStore(store) { viewStore in
            Input(
                text: viewStore.binding(
                    get: { $0.emailAddress },
                    send: { .didChangeEmailAddress($0) }
                ),
                isFirstResponder: $isEmailFieldFirstResponder,
                label: LocalizedString.TextFieldTitle.email,
                subText: !viewStore.isEmailValid && !viewStore.emailAddress.isEmpty ? LocalizedString.TextFieldError.invalidEmail : nil,
                subTextStyle: !viewStore.isEmailValid && !viewStore.emailAddress.isEmpty ? .error : .default,
                state: !viewStore.isEmailValid && !viewStore.emailAddress.isEmpty ? .error : .default,
                configuration: {
                    $0.autocorrectionType = .no
                    $0.autocapitalizationType = .none
                    $0.textContentType = .emailAddress
                    $0.keyboardType = .emailAddress
                    $0.placeholder = LocalizedString.TextFieldPlaceholder.email
                    $0.returnKeyType = .done
                    $0.enablesReturnKeyAutomatically = true
                },
                onReturnTapped: {
                    isEmailFieldFirstResponder = false
                    if viewStore.isEmailValid {
                        viewStore.send(.continueButtonTapped)
                    }
                }
            )
            .accessibility(identifier: AccessibilityIdentifiers.EmailLoginScreen.emailGroup)
            .disabled(viewStore.isLoading)
        }
    }
}

#if DEBUG
struct EmailLoginView_Previews: PreviewProvider {
    static var previews: some View {
        EmailLoginView(
            store:
            Store(
                initialState: .init(),
                reducer: emailLoginReducer,
                environment: .init(
                    app: App.preview,
                    mainQueue: .main,
                    sessionTokenService: NoOpSessionTokenService(),
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    errorRecorder: NoOpErrorRecoder(),
                    externalAppOpener: ToLogAppOpener(),
                    analyticsRecorder: NoOpAnalyticsRecorder(),
                    walletRecoveryService: .noop,
                    walletCreationService: .noop,
                    walletFetcherService: .noop,
                    accountRecoveryService: NoOpAccountRecoveryService(),
                    recaptchaService: NoOpGoogleRecatpchaService()
                )
            )
        )
    }
}
#endif
