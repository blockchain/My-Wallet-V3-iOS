// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI

struct ResetAccountWarningView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.ResetAccountWarning

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

    private let store: Store<ResetAccountWarningState, ResetAccountWarningAction>
    @ObservedObject private var viewStore: ViewStore<ResetAccountWarningState, ResetAccountWarningAction>

    init(store: Store<ResetAccountWarningState, ResetAccountWarningAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        PrimaryNavigationView {
            VStack {
                Spacer()
                Image.CircleIcon.resetAccount
                    .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                    .accessibility(identifier: AccessibilityIdentifiers.ResetAccountWarningScreen.resetAccountImage)

                Text(LocalizedString.Title.resetAccount)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                    .padding(.top, Layout.titleTopPadding)
                    .accessibility(identifier: AccessibilityIdentifiers.ResetAccountWarningScreen.resetAccountTitleText)

                Text(LocalizedString.Message.resetAccount)
                    .typography(.body1)
                    .foregroundColor(.semantic.text)
                    .lineSpacing(Layout.messageLineSpacing)
                    .accessibility(
                        identifier: AccessibilityIdentifiers.ResetAccountWarningScreen.resetAccountMessageText
                    )
                Spacer()

                PrimaryButton(title: LocalizedString.Button.continueReset) {
                    viewStore.send(.continueResetButtonTapped)
                }
                .padding(.bottom, Layout.buttonBottomPadding)
                .accessibility(identifier: AccessibilityIdentifiers.ResetAccountWarningScreen.continueToResetButton)

                MinimalButton(title: LocalizedString.Button.retryRecoveryPhrase) {
                    viewStore.send(.retryButtonTapped)
                }
                .accessibility(identifier: AccessibilityIdentifiers.ResetAccountWarningScreen.retryRecoveryPhraseButton)
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
            .navigationBarHidden(true)
            .onDisappear {
                viewStore.send(.onDisappear)
            }
        }
    }
}

#if DEBUG
struct ResetAccountWarningView_Previews: PreviewProvider {
    static var previews: some View {
        ResetAccountWarningView(
            store: .init(
                initialState: .init(),
                reducer: resetAccountWarningReducer,
                environment: .init(
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )
    }
}
#endif
