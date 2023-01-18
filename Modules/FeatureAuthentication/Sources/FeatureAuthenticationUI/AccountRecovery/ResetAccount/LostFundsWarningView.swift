// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct LostFundsWarningView: View {

    private typealias LocalizedStrings = LocalizationConstants.FeatureAuthentication.ResetAccountWarning

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

    private let store: Store<LostFundsWarningState, LostFundsWarningAction>
    @ObservedObject private var viewStore: ViewStore<LostFundsWarningState, LostFundsWarningAction>

    init(store: Store<LostFundsWarningState, LostFundsWarningAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            Spacer()
            Image.CircleIcon.warning
                .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                .accessibility(identifier: AccessibilityIdentifiers.LostFundsWarningScreen.lostFundsWarningImage)

            Text(LocalizedStrings.Title.lostFund)
                .textStyle(.title)
                .padding(.top, Layout.titleTopPadding)
                .accessibility(identifier: AccessibilityIdentifiers.LostFundsWarningScreen.lostFundsWarningTitleText)

            Text(LocalizedStrings.Message.lostFund.interpolating(NonLocalizedConstants.defiWalletTitle))
                .font(Font(weight: .medium, size: Layout.messageFontSize))
                .foregroundColor(.textSubheading)
                .lineSpacing(Layout.messageLineSpacing)
                .accessibility(identifier: AccessibilityIdentifiers.LostFundsWarningScreen.lostFundsWarningMessageText)
            Spacer()

            PrimaryButton(title: LocalizedStrings.Button.resetAccount) {
                viewStore.send(.resetAccountButtonTapped)
            }
            .padding(.bottom, Layout.buttonBottomPadding)
            .accessibility(identifier: AccessibilityIdentifiers.LostFundsWarningScreen.resetAccountButton)

            MinimalButton(title: LocalizedStrings.Button.goBack) {
                viewStore.send(.goBackButtonTapped)
            }
            .accessibility(identifier: AccessibilityIdentifiers.LostFundsWarningScreen.goBackButton)

            PrimaryNavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: \.resetPasswordState,
                        action: LostFundsWarningAction.resetPassword
                    ),
                    then: { store in
                        ResetPasswordView(store: store)
                    }
                ),
                isActive: viewStore.binding(
                    get: \.isResetPasswordScreenVisible,
                    send: LostFundsWarningAction.setResetPasswordScreenVisible(_:)
                ),
                label: EmptyView.init
            )
        }
        .multilineTextAlignment(.center)
        .padding(
            EdgeInsets(
                top: 0,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
    }
}

#if DEBUG
struct LostFundsWarningView_Previews: PreviewProvider {
    static var previews: some View {
        LostFundsWarningView(
            store: .init(
                initialState: .init(),
                reducer: lostFundsWarningReducer,
                environment: .init(
                    mainQueue: .main,
                    analyticsRecorder: NoOpAnalyticsRecorder(),
                    passwordValidator: NoOpPasswordValidator(),
                    externalAppOpener: NoOpExternalAppOpener(),
                    errorRecorder: NoOpErrorRecoder()
                )
            )
        )
    }
}
#endif
