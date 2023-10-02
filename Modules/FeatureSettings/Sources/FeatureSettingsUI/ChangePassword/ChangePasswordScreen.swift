// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ErrorsUI
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import Localization
import SwiftUI
import UIComponentsKit

private typealias LocalizedString = LocalizationConstants.Settings.ChangePassword

struct ChangePasswordView: View {

    private let store: Store<ChangePasswordState, ChangePasswordAction>
    @ObservedObject private var viewStore: ViewStore<ChangePasswordState, ChangePasswordAction>

    @State private var currentPassword = false
    @State private var newPassword = false
    @State private var confirmationPassword = false

    init(store: Store<ChangePasswordState, ChangePasswordAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: Spacing.padding3) {
                    header
                    form
                    BlockchainComponentLibrary.PrimaryButton(
                        title: LocalizedString.action,
                        isLoading: viewStore.loading
                    ) {
                        viewStore.send(.updatePassword)
                    }
                    .disabled(viewStore.isUpdateButtonDisabled)
                }
                .padding(Spacing.padding3)
                .frame(minHeight: geometry.size.height)
            }
            .onTapGesture {
                currentPassword = false
                newPassword = false
                confirmationPassword = false
            }
            .dismissKeyboardOnScroll()
        }
        .primaryNavigation(title: LocalizedString.title)
        .sheet(item: viewStore.binding(\.$fatalError)) { error in
            ErrorView(
                ux: error,
                navigationBarClose: true,
                fallback: {
                    ZStack {
                        Circle()
                            .fill(Color.semantic.light)
                            .frame(width: 88)
                        Icon.user
                            .color(.semantic.title)
                            .frame(width: 50)
                    }
                },
                dismiss: {
                    viewStore.send(.binding(.set(\.$fatalError, nil)))
                }
            )
        }
        .background(Color.semantic.light.ignoresSafeArea())
    }
}

extension ChangePasswordView {

    var header: some View {
        VStack(spacing: Spacing.padding3) {
            HStack {
                Text(LocalizedString.description)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
                Spacer()
            }
        }
    }
}

extension ChangePasswordView {

    var form: some View {
        VStack(spacing: Spacing.padding2) {
            currentPasswordField
            passwordField
            passwordConfirmationField
            Spacer()
        }
    }

    private var currentPasswordField: some View {
        VStack {
            Input(
                text: viewStore.binding(\.$current),
                isFirstResponder: $currentPassword,
                shouldResignFirstResponderOnReturn: true,
                label: LocalizationConstants.TextField.Title.currentPassword,
                isSecure: !viewStore.passwordFieldTextVisible,
                trailing: {
                    PasswordEyeSymbolButton(
                        isPasswordVisible: viewStore.binding(\.$passwordFieldTextVisible)
                    )
                }
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.newPassword)
        }
    }

    private var passwordField: some View {
        let shouldShowError = viewStore.passwordRulesBreached.isNotEmpty
        return VStack {
            Input(
                text: viewStore.binding(\.$new),
                isFirstResponder: $newPassword,
                shouldResignFirstResponderOnReturn: true,
                label: LocalizationConstants.TextField.Title.newPassword,
                subText: viewStore.new.isEmpty ? nil : viewStore.passwordRulesBreached.hint,
                subTextStyle: viewStore.new.isEmpty ? .primary : viewStore.passwordRulesBreached.inputSubTextStyle,
                state: shouldShowError ? .error : .default,
                isSecure: !viewStore.passwordFieldTextVisible,
                trailing: {
                    PasswordEyeSymbolButton(
                        isPasswordVisible: viewStore.binding(\.$passwordFieldTextVisible)
                    )
                }
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.newPassword)

            Text(PasswordValidationRule.displayString) { string in
                string.foregroundColor = .semantic.body

                for rule in viewStore.passwordRulesBreached {
                    if let range = string.range(of: rule.accent) {
                        string[range].foregroundColor = .semantic.error
                    }
                }
            }
            .typography(.caption1)
        }
    }

    private var passwordConfirmationField: some View {
        let shouldShowError = viewStore.confirmation.isNotEmpty && viewStore.confirmation != viewStore.new
        return Input(
            text: viewStore.binding(\.$confirmation),
            isFirstResponder: $confirmationPassword,
            shouldResignFirstResponderOnReturn: true,
            label: LocalizationConstants.TextField.Title.confirmNewPassword,
            subText: shouldShowError ? LocalizationConstants.FeatureAuthentication.CreateAccount.TextFieldError.passwordsDontMatch : nil,
            subTextStyle: .error,
            state: shouldShowError ? .error : .default,
            isSecure: !viewStore.passwordFieldTextVisible,
            trailing: {
                PasswordEyeSymbolButton(
                    isPasswordVisible: viewStore.binding(\.$passwordFieldTextVisible)
                )
            }
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .textContentType(.password)
    }
}

extension Text {
    init(_ string: String, configure: (inout AttributedString) -> Void) {
        var attributedString = AttributedString(string) /// create an `AttributedString`
        configure(&attributedString) /// configure using the closure
        self.init(attributedString) /// initialize a `Text`
    }
}

struct DismissKeyboard: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.scrollDismissesKeyboard(.interactively)
        } else {
            content
        }
    }
}

extension View {

    func dismissKeyboardOnScroll() -> some View {
        modifier(DismissKeyboard())
    }
}
