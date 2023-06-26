// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public enum SkipUpgradeRoute: NavigationRoute {
    case credentials

    @ViewBuilder
    public func destination(
        in store: Store<SkipUpgradeState, SkipUpgradeAction>
    ) -> some View {
        let viewStore = ViewStore(store)
        switch self {
        case .credentials:
            IfLetStore(
                store.scope(
                    state: \.credentialsState,
                    action: SkipUpgradeAction.credentials
                ),
                then: { store in
                    CredentialsView(
                        context: .walletInfo(viewStore.walletInfo),
                        store: store
                    )
                }
            )
        }
    }
}

struct SkipUpgradeView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.SkipUpgrade

    private enum Layout {
        static let bottomPadding: CGFloat = 34
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24

        static let imageSideLength: CGFloat = 72
        static let imageBottomPadding: CGFloat = 16
        static let descriptionFontSize: CGFloat = 16
        static let descriptionLineSpacing: CGFloat = 4
        static let buttonSpacing: CGFloat = 10
    }

    private let store: Store<SkipUpgradeState, SkipUpgradeAction>

    init(store: Store<SkipUpgradeState, SkipUpgradeAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                VStack {
                    Spacer()
                    Image.CircleIcon.warning
                        .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                        .padding(.bottom, Layout.imageBottomPadding)
                        .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.skipUpgradeImage)

                    Text(LocalizedString.title)
                        .textStyle(.title)
                        .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.skipUpgradeTitleText)

                    Text(LocalizedString.message)
                        .font(Font(weight: .medium, size: Layout.descriptionFontSize))
                        .foregroundColor(.textSubheading)
                        .lineSpacing(Layout.descriptionLineSpacing)
                        .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.skipUpgradeMessageText)
                    Spacer()
                }
                .multilineTextAlignment(.center)
                VStack(spacing: Layout.buttonSpacing) {
                    PrimaryButton(
                        title: LocalizedString.Button.skipUpgrade,
                        action: {
                            viewStore.send(.navigate(to: .credentials))
                        }
                    )
                    .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.skipUpgradeButton)

                    MinimalButton(
                        title: LocalizedString.Button.upgradeAccount,
                        action: {
                            viewStore.send(.returnToUpgradeButtonTapped)
                        }
                    )
                    .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.upgradeAccountButton)
                }
            }
            .padding(
                EdgeInsets(
                    top: 0,
                    leading: Layout.leadingPadding,
                    bottom: Layout.bottomPadding,
                    trailing: Layout.trailingPadding
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationRoute(in: store)
            .hideBackButtonTitle()
        }
    }
}

#if DEBUG
struct SkipUpgradeView_Previews: PreviewProvider {
    static var previews: some View {
        SkipUpgradeView(
            store: .init(
                initialState: .init(
                    walletInfo: .empty
                ),
                reducer: skipUpgradeReducer,
                environment: SkipUpgradeEnvironment(
                    mainQueue: .main,
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    errorRecorder: NoOpErrorRecoder(),
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
