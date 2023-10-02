// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// LargeAnnouncementCard from the Figma Component Library.
///
/// # Figma
///
///  [Cards](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A7478)
public struct LargeAnnouncementCard<Leading: View>: View {

    private let title: String
    private let message: String
    private let control: Control
    private let mainColor: Color
    private let primaryTopText: String
    private let secondaryTopText: String
    private let tertiaryTopText: String
    private let onCloseTapped: () -> Void
    private let leading: Leading

    private var buttonColorSet: PillButtonStyle.ColorSet {
        PillButtonStyle.ColorSet(
            foreground: .palette.white,
            background: mainColor,
            border: mainColor
        )
    }

    private var mainColorDark: Color {
        #if canImport(UIKit)
        guard let components = UIColor(mainColor).cgColor.components else { return mainColor }
        let darkenComponents = components.map { Double($0) * 0.8 }
        return Color(
            .sRGB,
            red: darkenComponents[0],
            green: darkenComponents[1],
            blue: darkenComponents[2],
            opacity: 1.0
        )
        #else
        return mainColor
        #endif
    }

    /// Initialize a Announcement Card
    /// - Parameters:
    ///   - title: Title of the card
    ///   - message: Message of the card
    ///   - control: Control object containing the title and action of the Card's button
    ///   - mainColor: Color to tint some elements of the card
    ///   - primaryTopText:Primary text on the top of the card
    ///   - secondaryTopText: Secondary text on the top of the card
    ///   - tertiaryTopText: Tertiary text on the top of the card
    ///   - onCloseTapped: Closure executed when the user types the close icon
    ///   - leading: View on the leading top of the card.
    public init(
        title: String,
        message: String,
        control: Control,
        mainColor: Color,
        primaryTopText: String,
        secondaryTopText: String,
        tertiaryTopText: String,
        onCloseTapped: @escaping () -> Void,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.message = message
        self.control = control
        self.mainColor = mainColor
        self.primaryTopText = primaryTopText
        self.secondaryTopText = secondaryTopText
        self.tertiaryTopText = tertiaryTopText
        self.onCloseTapped = onCloseTapped
        self.leading = leading()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topView()
            Spacer()
                .frame(height: 16)
            Text(title)
                .typography(.body2)
                .foregroundColor(.semantic.title)
            Spacer()
                .frame(height: 4)
            Text(message)
                .typography(.paragraph1)
                .foregroundColor(.semantic.title)
            Spacer()
                .frame(height: 16)
            PrimaryButton(
                title: control.title,
                leadingView: { EmptyView() },
                action: control.action
            )
            .colorCombination(
                PillButtonStyle.ColorCombination(
                    enabled: buttonColorSet,
                    pressed: PillButtonStyle.ColorSet(
                        foreground: .palette.white,
                        background: mainColorDark,
                        border: mainColorDark
                    ),
                    disabled: buttonColorSet,
                    progressViewRail: mainColor,
                    progressViewTrack: mainColor
                )
            )
        }
        .padding(Spacing.padding2)
        .background(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .fill(Color.semantic.background)
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
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .stroke(mainColor)
        )
    }

    @ViewBuilder private func topView() -> some View {
        HStack(alignment: .top, spacing: 8) {
            leading
                .accentColor(mainColor)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(primaryTopText)
                    .typography(.caption2)
                    .foregroundColor(.semantic.title)
                HStack(spacing: 4) {
                    Text(secondaryTopText)
                        .typography(.caption2)
                        .foregroundColor(.palette.green400)
                    Text(tertiaryTopText)
                        .typography(.caption2)
                        .foregroundColor(.palette.grey400)
                }
            }
            Spacer()
            Button(
                action: onCloseTapped,
                label: {
                    Icon.close
                        .circle(
                            backgroundColor: Color(
                                light: .semantic.medium,
                                dark: .palette.grey800
                            )
                        )
                        .color(.palette.grey400)
                        .frame(width: 24)
                }
            )
        }
    }
}

struct LargeAnnouncementCard_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            LargeAnnouncementCard(
                title: "Uniswap (UNI) is Now Trading",
                message: "Exchange, deposit, withdraw, or store UNI in your Blockchain.com Exchange account.",
                control: Control(title: "Trade UNI", action: {}),
                mainColor: .palette.red400,
                primaryTopText: "1 UNI = $21.19",
                secondaryTopText: "+$1.31 (5.22%)",
                tertiaryTopText: "Today",
                onCloseTapped: {},
                leading: {
                    Icon.trade
                }
            )
            .previewLayout(.sizeThatFits)

            LargeAnnouncementCard(
                title: "Uniswap (UNI) is Now Trading",
                message: "Exchange, deposit, withdraw, or store UNI in your Blockchain.com Exchange account.",
                control: Control(title: "Trade UNI", action: {}),
                mainColor: .palette.red400,
                primaryTopText: "1 UNI = $21.19",
                secondaryTopText: "+$1.31 (5.22%)",
                tertiaryTopText: "Today",
                onCloseTapped: {},
                leading: {
                    Icon.trade
                }
            )
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)

            LargeAnnouncementCard(
                title: "Title",
                message: "Message",
                control: Control(title: "Control Title", action: {}),
                mainColor: .palette.green700,
                primaryTopText: "PrimaryTopText",
                secondaryTopText: "SecondaryTopText",
                tertiaryTopText: "TertiaryTopText",
                onCloseTapped: {},
                leading: {
                    Icon.trade
                }
            )
            .previewLayout(.sizeThatFits)

            LargeAnnouncementCard(
                title: "Title",
                message: "Message",
                control: Control(title: "Control Title", action: {}),
                mainColor: .palette.green700,
                primaryTopText: "PrimaryTopText",
                secondaryTopText: "SecondaryTopText",
                tertiaryTopText: "TertiaryTopText",
                onCloseTapped: {},
                leading: {
                    Icon.trade
                }
            )
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)
        }
    }
}
