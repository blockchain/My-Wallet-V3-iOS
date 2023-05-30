// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformUIKit
import SwiftUI
import UIComponentsKit

struct InterestIdentityVerificationView: View {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.IdentityVerification
    private typealias LocalizationList = LocalizationId.List

    private let buttonTapped: () -> Void

    init(action: @escaping () -> Void) {
        self.buttonTapped = action
    }

    var body: some View {
        ActionableView(
            buttons: [.init(title: LocalizationId.action, action: buttonTapped)],
            content: {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        badgeImageViewWithViewModel(
                            .init(theme:
                                .init(
                                    backgroundColor: .defaultBadge,
                                    cornerRadius: .round,
                                    imageViewContent: .init(
                                        imageResource: .local(
                                            name: Icon.interest.name,
                                            bundle: .componentLibrary
                                        ),
                                        accessibility: .none,
                                        renderingMode: .template(.white)
                                    ),
                                    marginOffset: 8,
                                    sizingType: .constant(.edge(40))
                                )
                            )
                        )
                        .frame(width: 40, height: 40)
                        Text(LocalizationId.title)
                            .textStyle(.title)
                        Text(LocalizationId.description)
                            .textStyle(.subheading)
                    }
                    PrimaryDivider()
                    Spacer(minLength: Spacing.padding2)
                    VStack(alignment: .leading, spacing: Spacing.padding2) {
                        NumberedBadgeView(
                            badgeText: "1",
                            title: LocalizationList.First.title,
                            description: LocalizationList.First.description
                        )
                        NumberedBadgeView(
                            badgeText: "2",
                            title: LocalizationList.Second.title,
                            description: LocalizationList.Second.description
                        )
                        NumberedBadgeView(
                            badgeText: "3",
                            title: LocalizationList.Third.title,
                            description: LocalizationList.Third.description
                        )
                    }
                    Spacer(minLength: Spacing.padding2)
                }
            }
        )
    }

    private func badgeImageViewWithViewModel(_ viewModel: BadgeImageViewModel) -> some View {
        BadgeImageViewRepresentable(
            viewModel: viewModel,
            size: 40
        )
    }
}

struct NumberedBadgeView: View {

    private let badgeText: String
    private let title: String
    private let description: String

    init(
        badgeText: String,
        title: String,
        description: String
    ) {
        self.badgeText = badgeText
        self.title = title
        self.description = description
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16.0) {
            Text(badgeText)
                .textStyle(.heading)
                .foregroundColor(Color.buttonSecondaryText)
                .padding()
                .background(Color.badgeBackgroundInfo)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4.0) {
                Text(title)
                    .textStyle(.title)
                    .fixedSize(horizontal: false, vertical: true)
                Text(description)
                    .textStyle(.subheading)
            }
        }
    }

    private func badgeViewWithViewModel(_ viewModel: BadgeViewModel) -> some View {
        BadgeViewRepresentable(
            viewModel: viewModel,
            size: 32
        )
    }
}

struct InterestIdentityVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        InterestIdentityVerificationView(action: {})
    }
}
