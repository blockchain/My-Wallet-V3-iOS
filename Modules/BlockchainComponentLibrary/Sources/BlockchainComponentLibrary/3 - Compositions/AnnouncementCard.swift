// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import SwiftUI

/// AnnouncementCard from the Figma Component Library.
///
/// # Figma
///
///  [Cards](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A7478)
public struct AnnouncementCard<Leading: View, Background: View>: View {

    private let title: String
    private let message: String
    private let background: Background
    private let onCloseTapped: (() -> Void)?
    private let leading: Leading

    /// Initialize a Announcement Card
    /// - Parameters:
    ///   - title: Title of the card
    ///   - message: Message of the card
    ///   - background: Background to apply to announcement
    ///   - onCloseTapped: Closure executed when the user types the close icon
    ///   - leading: View on the leading of the card.
    public init(
        title: String,
        message: String,
        @ViewBuilder background: () -> Background,
        onCloseTapped: (() -> Void)? = nil,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.message = message
        self.background = background()
        self.onCloseTapped = onCloseTapped
        self.leading = leading()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 16) {
            HStack(spacing: 16) {
                leading
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .typography(.caption1)
                        .foregroundColor(.semantic.muted)
                    Text(message)
                        .lineLimit(3)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                }
            }
            Spacer()
            if let onCloseTapped {
                Button(
                    action: onCloseTapped,
                    label: {
                        Icon.close
                            .circle(backgroundColor: .palette.grey800)
                            .color(.palette.grey400)
                            .frame(width: 24)
                    }
                )
            }
        }
        .padding(Spacing.padding2)
        .background(background)
        .clipShape(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
        )
        .background(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .fill(
                    Color(
                        light: .palette.grey900,
                        dark: .palette.dark800
                    )
                )
                .shadow(
                    color: .palette.black.opacity(0.04),
                    radius: 1,
                    x: 0,
                    y: 3
                )
                .shadow(
                    color: .palette.black.opacity(0.12),
                    radius: 8,
                    x: 0,
                    y: 3
                )
        )
    }
}

extension AnnouncementCard where Background == AnyView {

    /// Initialize a Announcement Card
    /// - Parameters:
    ///   - title: Title of the card
    ///   - message: Message of the card
    ///   - onCloseTapped: Closure executed when the user types the close icon
    ///   - leading: View on the leading of the card.
    public init(
        title: String,
        message: String,
        onCloseTapped: (() -> Void)? = nil,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(
            title: title,
            message: message,
            background: {
                AnyView(
                    GeometryReader { proxy in
                        Image("PCB Faded", bundle: .componentLibrary)
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .offset(y: -proxy.size.height / 3)
                            .opacity(0.05)
                    }
                )
            },
            onCloseTapped: onCloseTapped,
            leading: leading
        )
    }
}

struct AnnouncementCard_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            AnnouncementCard(
                title: "New Asset",
                message: "Dogecoin (DOGE) is now available on Blockchain.",
                onCloseTapped: {},
                leading: {
                    Icon.wallet
                        .color(.semantic.gold)
                }
            )
            .previewLayout(.sizeThatFits)

            AnnouncementCard(
                title: "New Asset",
                message: "Dogecoin (DOGE) is now available on Blockchain.",
                onCloseTapped: {},
                leading: {
                    Icon.wallet
                        .color(.semantic.gold)
                }
            )
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)
        }
    }
}
