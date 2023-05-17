// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureAuthenticationDomain
import Localization
import SwiftUI

public struct AuthorizationResultView: View {

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

    public var okButtonPressed: (() -> Void)?

    private let iconImage: Image
    private let title: String
    private let description: String

    public init(
        iconImage: Image,
        title: String,
        description: String
    ) {
        self.iconImage = iconImage
        self.title = title
        self.description = description
    }

    public var body: some View {
        VStack {
            Spacer()
            iconImage
                .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                .padding(.bottom, Layout.imageBottomPadding)
                .accessibility(identifier: AccessibilityIdentifiers.AuthorizationResultScreen.image)
            Text(title)
                .textStyle(.title)
                .foregroundColor(.semantic.title)
                .accessibility(identifier: AccessibilityIdentifiers.AuthorizationResultScreen.title)
            Text(description)
                .typography(.body1)
                .foregroundColor(.semantic.text)
                .lineSpacing(Layout.descriptionLineSpacing)
                .accessibility(identifier: AccessibilityIdentifiers.AuthorizationResultScreen.message)
            Spacer()
            PrimaryButton(title: LocalizationConstants.okString) {
                okButtonPressed?()
            }
            .accessibility(identifier: AccessibilityIdentifiers.AuthorizationResultScreen.button)
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
    }
}

extension AuthorizationResultView {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.AuthorizationResult

    public static let success: AuthorizationResultView = .init(
        iconImage: Image("icon_authorized"),
        title: LocalizedString.Success.title,
        description: LocalizedString.Success.message
    )

    public static let linkExpired: AuthorizationResultView = .init(
        iconImage: Image("icon_link_expired"),
        title: LocalizedString.LinkExpired.title,
        description: LocalizedString.LinkExpired.message
    )

    public static let rejected: AuthorizationResultView = .init(
        iconImage: Image("icon_rejected"),
        title: LocalizedString.DeviceRejected.title,
        description: LocalizedString.DeviceRejected.message
    )

    public static let unknown: AuthorizationResultView = .init(
        iconImage: Image("icon_unknown_error"),
        title: LocalizedString.Unknown.title,
        description: LocalizedString.Unknown.message
    )
}

#if DEBUG
private struct AuthorizationResultView_Previews: PreviewProvider {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.AuthorizationResult

    static var previews: some View {
        AuthorizationResultView(
            iconImage: Image("icon_authorized"),
            title: LocalizedString.Success.title,
            description: LocalizedString.Success.message
        )
    }
}
#endif
