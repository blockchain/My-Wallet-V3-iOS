// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public struct SecondPasswordNoticeReducer: Reducer {
    public enum URLContent: Equatable {
        case loginOnWeb
        case twoFASupport

        var url: URL? {
            switch self {
            case .loginOnWeb:
                return URL(string: Constants.HostURL.loginOnWeb)
            case .twoFASupport:
                return URL(string: Constants.SupportURL.SecondPassword.twoFASupport)
            }
        }
    }

    public struct State: Equatable {}

    public enum Action: Equatable {
        case open(urlContent: URLContent)
        case returnTapped
    }

    let externalAppOpener: ExternalAppOpener

    public var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .open(let urlContent):
                guard let url = urlContent.url else {
                    return .none
                }
                externalAppOpener.open(url)
                return .none
            case .returnTapped:
                return .none
            }
        }
    }
}

public struct SecondPasswordNoticeView: View {

    private typealias LocalizedConstants = LocalizationConstants.FeatureAuthentication.SecondPasswordScreen
    private typealias AccessibilityIdentifier = AccessibilityIdentifiers.SecondPasswordScreen

    private enum Layout {
        static let bottomPadding: CGFloat = 34
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24

        static let imageBottomPadding: CGFloat = 16
        static let descriptionFontSize: CGFloat = 16
        static let descriptionLineSpacing: CGFloat = 4
        static let buttonSpacing: CGFloat = 10
    }

    private let store: Store<SecondPasswordNoticeReducer.State, SecondPasswordNoticeReducer.Action>

    public init(store: Store<SecondPasswordNoticeReducer.State, SecondPasswordNoticeReducer.Action>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                VStack {
                    Spacer()
                    Image.CircleIcon.lockedIcon
                        .padding(.bottom, Layout.imageBottomPadding)
                        .accessibility(identifier: AccessibilityIdentifier.lockedIconImage)

                    Text(LocalizedConstants.title)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                        .accessibility(identifier: AccessibilityIdentifier.titleText)

                    Text(LocalizedConstants.description)
                        .typography(.body1)
                        .foregroundColor(.semantic.text)
                        .lineSpacing(Layout.descriptionLineSpacing)
                        .accessibility(
                            identifier: AccessibilityIdentifier.descriptionText
                        )
                    SmallMinimalButton(title: LocalizedConstants.learnMore) {
                        viewStore.send(.open(urlContent: .twoFASupport))
                    }
                    .accessibility(identifier: AccessibilityIdentifier.learnMoreText)
                    Spacer()
                }
                .multilineTextAlignment(.center)

                VStack(spacing: Layout.buttonSpacing) {
                    PrimaryButton(
                        title: LocalizedConstants.loginOnWebButtonTitle,
                        action: { viewStore.send(.open(urlContent: .loginOnWeb)) }
                    )
                    .accessibility(identifier: AccessibilityIdentifier.loginOnWebButton)
                    MinimalButton(
                        title: LocalizedConstants.returnToLogin,
                        action: { viewStore.send(.returnTapped) }
                    )
                    .accessibility(identifier: AccessibilityIdentifier.returnButton)
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
            .navigationBarBackButtonHidden(true)
            .primaryNavigation(title: "")
            .background(Color.semantic.light.ignoresSafeArea())
        }
    }
}

#if DEBUG
struct SecondPasswordNoticeView_Previews: PreviewProvider {
    static var previews: some View {
        SecondPasswordNoticeView(
            store: Store(
                initialState: .init(),
                reducer: {
                    SecondPasswordNoticeReducer(
                        externalAppOpener: ToLogAppOpener()
                    )
                }
            )
        )
    }
}
#endif
