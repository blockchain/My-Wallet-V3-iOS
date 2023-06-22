// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public enum WelcomeRoute: NavigationRoute {
    case createWallet
    case emailLogin
    case restoreWallet
    case manualLogin

    @ViewBuilder
    public func destination(
        in store: Store<WelcomeState, WelcomeAction>
    ) -> some View {
        switch self {
        case .createWallet:
            IfLetStore(
                store.scope(
                    state: \.createWalletState,
                    action: WelcomeAction.createWallet
                ),
                then: CreateAccountStepOneView.init(store:)
            )
        case .emailLogin:
            IfLetStore(
                store.scope(
                    state: \.emailLoginState,
                    action: WelcomeAction.emailLogin
                ),
                then: EmailLoginView.init(store:)
            )
        case .restoreWallet:
            IfLetStore(
                store.scope(
                    state: \.restoreWalletState,
                    action: WelcomeAction.restoreWallet
                ),
                then: SeedPhraseView.init(store:)
            )
        case .manualLogin:
            IfLetStore(
                store.scope(
                    state: \.manualCredentialsState,
                    action: WelcomeAction.manualPairing
                ),
                then: { store in
                    CredentialsView(
                        context: .manualPairing,
                        store: store
                    )
                }
            )
        }
    }
}

private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.Welcome

private enum Layout {
    static let topPadding: CGFloat = 140
    static let bottomPadding: CGFloat = 58
    static let leadingPadding: CGFloat = 24
    static let trailingPadding: CGFloat = 24

    static let imageSideLength: CGFloat = 64
    static let imageBottomPadding: CGFloat = 40
    static let titleFontSize: CGFloat = 24
    static let subtitleFontSize: CGFloat = 18
    static let titleBottomPadding: CGFloat = 16
    static let messageFontSize: CGFloat = 16
    static let messageLineSpacing: CGFloat = 4
    static let buttonSpacing: CGFloat = 10
    static let buttonFontSize: CGFloat = 16
    static let buttonBottomPadding: CGFloat = 20
    static let supplmentaryTextFontSize: CGFloat = 12
}

/// Entry point to Create Wallet/Login/Restore Wallet
/// NOT currently used - old UI
public struct WelcomeView: View {

    private let store: Store<WelcomeState, WelcomeAction>
    @ObservedObject private var viewStore: ViewStore<WelcomeState, WelcomeAction>

    public init(store: Store<WelcomeState, WelcomeAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            welcomeMessageSection
            Spacer()
            buttonSection
                .padding(.vertical, Layout.buttonBottomPadding)
            supplementarySection
        }
        .padding(
            EdgeInsets(
                top: Layout.topPadding,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
        .navigationRoute(in: store)
    }

    // MARK: - Private

    private var welcomeMessageSection: some View {
        VStack {
            Image.Logo.blockchain
                .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                .padding(.bottom, Layout.imageBottomPadding)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.blockchainImage)
            Text(LocalizedString.title)
                .font(Font(weight: .semibold, size: Layout.titleFontSize))
                .foregroundColor(.semantic.text)
                .padding(.bottom, Layout.titleBottomPadding)
            Text(LocalizedString.subtitle)
                .font(Font(weight: .semibold, size: Layout.subtitleFontSize))
                .foregroundColor(.semantic.text)
                .padding(.bottom, Layout.titleBottomPadding)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.welcomeSubtitleText)
            welcomeMessageDescription
                .typography(.body1)
                .lineSpacing(Layout.messageLineSpacing)
                .fixedSize(horizontal: false, vertical: true)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.welcomeMessageText)
        }
        .multilineTextAlignment(.center)
    }

    private var welcomeMessageDescription: some View {
        Text(LocalizedString.Description.prefix)
            .foregroundColor(.semantic.muted) +
            Text(LocalizedString.Description.send)
            .foregroundColor(.semantic.title) +
            Text(LocalizedString.Description.comma)
            .foregroundColor(.semantic.muted) +
            Text(LocalizedString.Description.receive)
            .foregroundColor(.semantic.title) +
            Text(LocalizedString.Description.comma)
            .foregroundColor(.semantic.muted) +
            Text(LocalizedString.Description.store + "\n")
            .foregroundColor(.semantic.title) +
            Text(LocalizedString.Description.and)
            .foregroundColor(.semantic.muted) +
            Text(LocalizedString.Description.trade)
            .foregroundColor(.semantic.title) +
            Text(LocalizedString.Description.suffix)
            .foregroundColor(.semantic.muted)
    }

    private var buttonSection: some View {
        VStack(spacing: Layout.buttonSpacing) {
            PrimaryButton(title: LocalizedString.Button.createWallet) {
                viewStore.send(.navigate(to: .createWallet))
            }
            .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.createWalletButton)
            MinimalButton(title: LocalizedString.Button.login) {
                viewStore.send(.navigate(to: .emailLogin))
            }
            .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.emailLoginButton)
            if viewStore.manualPairingEnabled {
                Divider()
                manualPairingButton()
                    .accessibility(
                        identifier: AccessibilityIdentifiers.WelcomeScreen.manualPairingButton
                    )
            }
        }
        .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.emailLoginButton)
    }

    private var supplementarySection: some View {
        HStack {
            Button(LocalizedString.Button.restoreWallet) {
                viewStore.send(.navigate(to: .restoreWallet))
            }
            .buttonStyle(ExpandedButtonStyle(EdgeInsets(top: 15, leading: 0, bottom: 20, trailing: 20)))
            .typography(.caption2)
            .foregroundColor(.semantic.primary)
            .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.restoreWalletButton)
            Spacer()
            Text(viewStore.buildVersion)
                .typography(.caption1)
                .foregroundColor(.semantic.muted)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.buildVersionText)
        }
    }

    private func manualPairingButton() -> some View {
        Button(LocalizedString.Button.manualPairing) {
            viewStore.send(.navigate(to: .manualLogin))
        }
        .typography(.body2)
        .frame(maxWidth: .infinity, minHeight: ButtonSize.Standard.height)
        .padding(.horizontal)
        .foregroundColor(Color.semantic.text)
        .background(
            RoundedRectangle(cornerRadius: ButtonSize.Standard.cornerRadius)
                .fill(Color.semantic.background)
        )
        .background(
            RoundedRectangle(cornerRadius: ButtonSize.Standard.cornerRadius)
                .stroke(Color.semantic.light)
        )
    }
}

private struct ExpandedButtonStyle: ButtonStyle {
    private let padding: EdgeInsets

    init(_ padding: EdgeInsets) {
        self.padding = padding
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .buttonLinkText.opacity(0.5) : .buttonLinkText)
            .padding(padding)
            .contentShape(Rectangle())
    }
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(
            store: Store(
                initialState: .init(),
                reducer: welcomeReducer,
                environment: .init(
                    app: App.preview,
                    mainQueue: .main,
                    sessionTokenService: NoOpSessionTokenService(),
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    recaptchaService: NoOpGoogleRecatpchaService(),
                    buildVersionProvider: { "Test version" }
                )
            )
        )
    }
}
#endif
