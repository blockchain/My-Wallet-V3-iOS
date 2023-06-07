// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

struct ImportWalletView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.ImportWallet

    private enum Layout {
        static let imageSideLength: CGFloat = 72

        static let messageFontSize: CGFloat = 16
        static let messageLineSpacing: CGFloat = 4

        static let bottomPadding: CGFloat = 34
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24
        static let titleTopPadding: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 10
    }

    private let store: Store<ImportWalletState, ImportWalletAction>
    @ObservedObject private var viewStore: ViewStore<ImportWalletState, ImportWalletAction>

    init(store: Store<ImportWalletState, ImportWalletAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            VStack {
                Spacer()
                Image.CircleIcon.importWallet
                    .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                    .accessibility(identifier: AccessibilityIdentifiers.ImportWalletScreen.importWalletImage)

                Text(LocalizedString.importWalletTitle)
                    .typography(.title3)
                    .foregroundColor(.semantic.text)
                    .padding(.top, Layout.titleTopPadding)
                    .accessibility(identifier: AccessibilityIdentifiers.ImportWalletScreen.importWalletTitleText)

                Text(LocalizedString.importWalletMessage)
                    .typography(.body1)
                    .foregroundColor(.semantic.text)
                    .lineSpacing(Layout.messageLineSpacing)
                    .accessibility(identifier: AccessibilityIdentifiers.ImportWalletScreen.importWalletMessageText)
                Spacer()
            }
            VStack {
                PrimaryButton(title: LocalizedString.Button.importWallet) {
                    viewStore.send(.importWalletButtonTapped)
                }
                .padding(.bottom, Layout.buttonBottomPadding)
                MinimalButton(title: LocalizedString.Button.goBack) {
                    viewStore.send(.goBackButtonTapped)
                }
            }
            PrimaryNavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: \.createAccountState,
                        action: ImportWalletAction.createAccount
                    ),
                    then: CreateAccountStepOneView.init(store:)
                ),
                isActive: viewStore.binding(
                    get: \.isCreateAccountScreenVisible,
                    send: ImportWalletAction.setCreateAccountScreenVisible(_:)
                ),
                label: EmptyView.init
            )
        }
        .primaryNavigation()
        .padding(
            EdgeInsets(
                top: 0,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
        .background(Color.semantic.light.ignoresSafeArea())
    }
}

#if DEBUG
import AnalyticsKit
import BlockchainNamespace
import FeatureAuthenticationDomain
import ToolKit

struct ImportWalletView_Previews: PreviewProvider {
    static var previews: some View {
        ImportWalletView(
            store: .init(
                initialState: .init(mnemonic: ""),
                reducer: importWalletReducer,
                environment: .init(
                    mainQueue: .main,
                    passwordValidator: PasswordValidator(),
                    externalAppOpener: ToLogAppOpener(),
                    analyticsRecorder: NoOpAnalyticsRecorder(),
                    walletRecoveryService: .noop,
                    walletCreationService: .noop,
                    walletFetcherService: .noop,
                    signUpCountriesService: NoSignUpCountriesService(),
                    featureFlagsService: NoOpFeatureFlagsService(), recaptchaService: NoOpGoogleRecatpchaService(),
                    app: App.preview
                )
            )
        )
    }
}
#endif
