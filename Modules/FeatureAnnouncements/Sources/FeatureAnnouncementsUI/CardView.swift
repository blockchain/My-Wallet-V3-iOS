// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureAnnouncementsDomain
import SwiftUI

@MainActor
struct CardView: View {

    let announcement: Announcement
    let shadowed: Bool
    let action: () -> Void

    init(
        announcement: Announcement,
        shadowed: Bool,
        action: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.shadowed = shadowed
        self.action = action
    }

    var body: some View {
        HStack(alignment: .center, spacing: .zero) {
            if let url = announcement.content.imageUrl {
                AsyncMedia(url: url)
                    .frame(width: 40, height: 40)
                    .padding(.leading, Spacing.padding2)
            }
            VStack(alignment: .leading) {
                Text(announcement.content.title)
                    .typography(.caption1)
                    .foregroundColor(.semantic.muted)
                    .bold()
                Text(announcement.content.description)
                    .typography(.body2)
            }
            .padding(16)
            Spacer()
        }
        .frame(minHeight: 98)
        .background(Color.semantic.background)
        .cornerRadius(16)
        .padding(.horizontal, Spacing.padding2)
        .shadow(
            color: shadowed ? Color.black.opacity(0.12) : .clear,
            radius: 4,
            x: 0,
            y: 3
        )
        .onTapGesture {
            action()
        }
    }
}
