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

public enum UpgradeAccountRoute: NavigationRoute {
    case skipUpgrade
    case webUpgrade

    @ViewBuilder
    public func destination(
        in store: Store<UpgradeAccountState, UpgradeAccountAction>
    ) -> some View {
        let viewStore = ViewStore(store)
        switch self {
        case .skipUpgrade:
            IfLetStore(
                store.scope(
                    state: \.skipUpgradeState,
                    action: UpgradeAccountAction.skipUpgrade
                ),
                then: SkipUpgradeView.init(store:)
            )
        case .webUpgrade:
            WebUpgradeAccountView(
                currentMessage: .constant(viewStore.currentMessage),
                connectionStatusCallback: { _ in
                    viewStore.send(.setCurrentMessage(viewStore.base64Str))
                },
                credentialsCallback: { _ in
                    // dismiss the web upgrade screen when received a callback
                    viewStore.send(.dismiss())
                }
            )
        }
    }
}

struct UpgradeAccountView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.UpgradeAccount

    private enum Layout {
        static let topPadding: CGFloat = 50
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 34

        static let headingBottomPadding: CGFloat = 8
        static let subheadingFontSize: CGFloat = 16
        static let subheadingLineSpacing: CGFloat = 5
        static let subheadingBottomPadding: CGFloat = 32

        static let buttonSpacing: CGFloat = 10
    }

    private let store: Store<UpgradeAccountState, UpgradeAccountAction>
    private let exchangeOnly: Bool

    init(
        store: Store<UpgradeAccountState, UpgradeAccountAction>,
        exchangeOnly: Bool
    ) {
        self.store = store
        self.exchangeOnly = exchangeOnly
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                VStack {
                    Text(LocalizedString.heading)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                        .padding(.bottom, Layout.headingBottomPadding)
                    Text(LocalizedString.subheading)
                        .lineSpacing(Layout.subheadingLineSpacing)
                        .typography(.body1)
                        .foregroundColor(.semantic.text)
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, Layout.subheadingBottomPadding)

                MessageList(messages: createMessages(exchangeOnly: exchangeOnly))
                Spacer()

                VStack {
                    PrimaryButton(
                        title: LocalizedString.upgradeAccountButton,
                        action: {
                            viewStore.send(.enter(into: .webUpgrade, context: .fullScreen))
                        }
                    )
                    .accessibilityIdentifier(AccessibilityIdentifiers.UpgradeAccountScreen.upgradeButton)

                    MinimalButton(
                        title: LocalizedString.skipButton,
                        action: {
                            viewStore.send(.navigate(to: .skipUpgrade))
                        }
                    )
                    .accessibilityIdentifier(AccessibilityIdentifiers.UpgradeAccountScreen.skipButton)
                }
            }
            .padding(
                EdgeInsets(
                    top: Layout.topPadding,
                    leading: Layout.leadingPadding,
                    bottom: Layout.bottomPadding,
                    trailing: Layout.trailingPadding
                )
            )
            .navigationTitle(LocalizedString.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationRoute(in: store)
            .hideBackButtonTitle()
        }
    }

    private struct Message: Identifiable {
        let id: Int
        let iconName: String
        let title: String
        let detailedMessage: String
    }

    private struct MessageList: View {

        let messages: [Message]

        var body: some View {
            VStack(alignment: .leading) {
                ForEach(messages) {
                    MessageRow(message: $0)
                        .padding(.top, 5)
                        .padding(.bottom, 25)
                }
            }
        }
    }

    private struct MessageRow: View {

        let message: Message

        var body: some View {
            HStack(alignment: .top) {
                Image(message.iconName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 5)
                VStack(alignment: .leading) {
                    Text(message.title)
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                    Text(message.detailedMessage)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.text)
                }
            }
        }
    }

    private func createMessages(exchangeOnly: Bool) -> [Message] {
        var messages: [Message] = [
            Message(
                id: 1,
                iconName: "number-one",
                title: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.headingOne,
                detailedMessage: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.bodyOne
            ),
            Message(
                id: 2,
                iconName: "number-two",
                title: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.headingTwo,
                detailedMessage: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.bodyTwo
            )
        ]
        if exchangeOnly {
            messages.append(
                Message(
                    id: 3,
                    iconName: "number-three",
                    title: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.headingThree,
                    detailedMessage: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.bodyThree
                )
            )
        }
        return messages
    }
}

#if DEBUG
struct UpgradeAccountView_Previews: PreviewProvider {
    static var previews: some View {
        UpgradeAccountView(
            store: .init(
                initialState: .init(
                    walletInfo: .empty,
                    base64Str: ""
                ),
                reducer: upgradeAccountReducer,
                environment: UpgradeAccountEnvironment(
                    mainQueue: .main,
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    errorRecorder: NoOpErrorRecoder(),
                    featureFlagsService: NoOpFeatureFlagsService(),
                    analyticsRecorder: NoOpAnalyticsRecorder(),
                    walletRecoveryService: .noop,
                    walletCreationService: .noop,
                    walletFetcherService: .noop,
                    accountRecoveryService: NoOpAccountRecoveryService(),
                    recaptchaService: NoOpGoogleRecatpchaService()
                )
            ),
            exchangeOnly: true
        )
    }
}
#endif
