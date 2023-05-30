// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct ResetPasswordView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.ResetPassword

    private enum Layout {
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24
        static let topPadding: CGFloat = 34
        static let bottomPadding: CGFloat = 34
        static let textFieldSpacing: CGFloat = 16
        static let messageFontSize: CGFloat = 12
        static let callOutMessageTopPadding: CGFloat = 10
        static let callOutMessageCornerRadius: CGFloat = 8
    }

    private let store: Store<ResetPasswordState, ResetPasswordAction>
    @ObservedObject private var viewStore: ViewStore<ResetPasswordState, ResetPasswordAction>

    @State private var isNewPasswordFieldFirstResponder = true
    @State private var isConfirmNewPasswordFieldFirstResponder = false
    @State private var isPasswordVisible = false
    @State private var isConfirmNewPasswordVisible = false

    private var continueDisabled: Bool {
        viewStore.newPassword.isEmpty
            || viewStore.newPassword != viewStore.confirmNewPassword
            || viewStore.passwordStrength == .weak
    }

    init(
        store: Store<ResetPasswordState, ResetPasswordAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading) {
            newPasswordField
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.newPasswordGroup)

            passwordInstruction
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.passwordInstructionText)

            PasswordStrengthIndicatorView(
                passwordStrength: viewStore.binding(
                    get: \.passwordStrength,
                    send: .none
                )
            )
            .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.passwordStrengthIndicatorGroup)

            confirmNewPasswordField
                .padding(.top, Layout.textFieldSpacing)
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.confirmNewPasswordGroup)

            securityCallOut
                .padding(.top, Layout.callOutMessageTopPadding)
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.securityCallOutGroup)

            Spacer()

            PrimaryButton(
                title: LocalizedString.Button.resetPassword,
                isLoading: viewStore.isLoading
            ) {
                viewStore.send(.reset(password: viewStore.newPassword))
            }
            .disabled(continueDisabled)
            .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.resetPasswordButton)

            PrimaryNavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: \.resetAccountFailureState,
                        action: ResetPasswordAction.resetAccountFailure
                    ),
                    then: { store in
                        ResetAccountFailureView(store: store)
                    }
                ),
                isActive: viewStore.binding(
                    get: \.isResetAccountFailureVisible,
                    send: ResetPasswordAction.setResetAccountFailureVisible(_:)
                ),
                label: EmptyView.init
            )
        }
        .primaryNavigation(title: LocalizedString.navigationTitle) {
            Button {
                viewStore.send(.reset(password: viewStore.newPassword))
            } label: {
                Text(LocalizedString.Button.next)
                    .typography(.paragraph2)
                    .foregroundColor(
                        continueDisabled ? .semantic.muted : .semantic.primary
                    )
            }
            .disabled(continueDisabled)
            .accessibility(identifier: AccessibilityIdentifiers.SeedPhraseScreen.nextButton)
        }
        .padding(
            EdgeInsets(
                top: Layout.topPadding,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
    }

    private var newPasswordField: some View {
        Input(
            text: viewStore.binding(
                get: \.newPassword,
                send: { .didChangeNewPassword($0) }
            ),
            isFirstResponder: $isNewPasswordFieldFirstResponder,
            label: LocalizedString.TextFieldTitle.newPassword,
            configuration: {
                $0.isSecureTextEntry = !isPasswordVisible
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.placeholder = LocalizedString.TextFieldPlaceholder.newPassword
                $0.textContentType = .newPassword
            },
            trailing: {
                PasswordEyeSymbolButton(isPasswordVisible: $isPasswordVisible)
            },
            onReturnTapped: {
                isNewPasswordFieldFirstResponder = false
                isConfirmNewPasswordFieldFirstResponder = true
            }
        )
    }

    private var passwordInstruction: some View {
        Text(LocalizedString.passwordInstruction)
            .typography(.caption1)
            .foregroundColor(.semantic.text)
    }

    private var confirmNewPasswordField: some View {
        Input(
            text: viewStore.binding(
                get: \.confirmNewPassword,
                send: { .didChangeConfirmNewPassword($0) }
            ),
            isFirstResponder: $isConfirmNewPasswordFieldFirstResponder,
            label: LocalizedString.TextFieldTitle.confirmNewPassword,
            state: viewStore.newPassword != viewStore.confirmNewPassword ? .error : .default,
            configuration: {
                $0.isSecureTextEntry = !isConfirmNewPasswordVisible
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.placeholder = LocalizedString.TextFieldPlaceholder.confirmNewPassword
                $0.textContentType = .newPassword
            },
            trailing: {
                PasswordEyeSymbolButton(isPasswordVisible: $isConfirmNewPasswordVisible)
            },
            onReturnTapped: {
                isNewPasswordFieldFirstResponder = false
                isConfirmNewPasswordFieldFirstResponder = false
            }
        )
    }

    private var securityCallOut: some View {
        HStack {
            Text(LocalizedString.securityCallOut + " ")
                .foregroundColor(.semantic.body)
            +
            Text(LocalizedString.Button.learnMore)
                .foregroundColor(.semantic.primary)
        }
        .typography(.caption1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(
            RoundedRectangle(cornerRadius: Layout.callOutMessageCornerRadius)
                .fill(Color.semantic.light)
        )
        .onTapGesture {
            viewStore.send(.open(urlContent: .identifyVerificationOverview))
        }
    }
}

#if DEBUG
struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(
            store: .init(
                initialState: .init(),
                reducer: resetPasswordReducer,
                environment: .init(
                    mainQueue: .main,
                    passwordValidator: PasswordValidator(),
                    externalAppOpener: NoOpExternalAppOpener(),
                    errorRecorder: NoOpErrorRecoder()
                )
            )
        )
    }
}
#endif
