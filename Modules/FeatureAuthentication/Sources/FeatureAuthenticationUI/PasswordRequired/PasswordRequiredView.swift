// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public struct PasswordRequiredView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.PasswordRequired

    private let store: Store<PasswordRequiredState, PasswordRequiredAction>

    public init(store: Store<PasswordRequiredState, PasswordRequiredAction>) {
        self.store = store
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: Spacing.padding3) {
                    passwordRequiredHeader
                    passwordRequiredForm
                    Spacer()
                    forgetWalletSection
                }
                .padding(Spacing.padding3)
                .alert(store.scope(state: \.alert), dismiss: .alert(.dismiss))
            }
            .frame(height: geometry.size.height)
        }
    }

    private var passwordRequiredHeader: some View {
        VStack(spacing: Spacing.padding3) {
            Icon.lockClosed
                .color(.semantic.primary)
                .frame(width: 48, height: 48)
            Text(LocalizedString.title)
                .typography(.title2)
        }
        .accessibility(identifier: AccessibilityIdentifiers.PasswordRequiredScreen.header)
    }

    private var passwordRequiredForm: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                walletIdField
                passwordField
                PrimaryButton(title: LocalizedString.continueButton) {
                    viewStore.send(.continueButtonTapped)
                }
            }
        }
    }

    private var walletIdField: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding1) {
                Input(
                    text: .constant(viewStore.walletIdentifier),
                    isFirstResponder: .constant(false),
                    label: LocalizedString.walletIdentifier,
                    state: .default
                )
                .disabled(true)
                .accessibility(identifier: AccessibilityIdentifiers.PasswordRequiredScreen.walletIdGroup)
                Text(LocalizedString.description)
                    .typography(.caption1)
                    .foregroundColor(.textDetail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibility(identifier: AccessibilityIdentifiers.PasswordRequiredScreen.description)
            }
        }
    }

    private var passwordField: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: Spacing.padding1) {
                Input(
                    text: viewStore.binding(\.$password),
                    isFirstResponder: viewStore
                        .binding(\.$isPasswordSelected),
                    label: LocalizedString.passwordField,
                    placeholder: LocalizedString.passwordFieldPlaceholder,
                    configuration: {
                        $0.isSecureTextEntry = !viewStore.isPasswordVisible
                        $0.textContentType = .password
                    },
                    trailing: {
                        PasswordEyeSymbolButton(isPasswordVisible: viewStore.binding(\.$isPasswordVisible))
                    },
                    onReturnTapped: {
                        viewStore.send(.set(\.$isPasswordSelected, false))
                        viewStore.send(.continueButtonTapped)
                    }
                )
                Button {
                    viewStore.send(.forgotPasswordTapped)
                } label: {
                    Text(LocalizedString.forgotButton)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.primary)
                }
            }
        }
        .accessibility(identifier: AccessibilityIdentifiers.PasswordRequiredScreen.passwordGroup)
    }

    private var forgetWalletSection: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding2) {
                Text(LocalizedString.forgetWalletDescription)
                    .typography(.caption1)
                    .foregroundColor(.textDetail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibility(identifier: AccessibilityIdentifiers.PasswordRequiredScreen.forgotWalletDesription)
                DestructiveMinimalButton(title: LocalizedString.forgetWalletButton) {
                    viewStore.send(.forgetWalletTapped)
                }
                .accessibility(identifier: AccessibilityIdentifiers.PasswordRequiredScreen.forgotWalletButton)
            }
        }
    }
}
