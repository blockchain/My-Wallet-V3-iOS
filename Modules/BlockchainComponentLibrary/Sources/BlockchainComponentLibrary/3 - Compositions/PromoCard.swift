// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// PromoCard from the Figma Component Library.
///
/// # Figma
///
///  [Cards](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A7478)
public struct PromoCard: View {

    private let title: String
    private let message: String
    private let icon: Icon
    private let control: Control?
    private let onCloseTapped: () -> Void

    /// Initialize a Promo Card
    /// - Parameters:
    ///   - title: Title of the card
    ///   - message: Message of the card
    ///   - icon: Icon on top of the card
    ///   - control: Control object containing the title and action of the Card's button
    ///   - onCloseTapped: Closure executed when the user types the close icon
    public init(
        title: String,
        message: String,
        icon: Icon,
        control: Control? = nil,
        onCloseTapped: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.control = control
        self.onCloseTapped = onCloseTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                icon
                    .circle(
                        backgroundColor: Color(
                            light: .palette.blue000,
                            dark: .palette.blue600
                        )
                    )
                    .color(
                        Color(
                            light: .palette.blue600,
                            dark: .palette.blue000
                        )
                    )
                    .frame(width: 32)
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
            Spacer()
                .frame(height: 18)
            Text(title)
                .typography(.title3)
                .foregroundColor(.semantic.title)
            Spacer()
                .frame(height: control == nil ? 8 : 4)
            Text(message)
                .typography(.paragraph1)
                .foregroundColor(.semantic.title)
                .fixedSize(horizontal: false, vertical: true)
            if let control {
                Spacer()
                    .frame(height: 16)
                PrimaryButton(title: control.title, action: control.action)
            }
        }
        .padding(Spacing.padding2)
        .background(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .fill(
                    Color(
                        light: .semantic.background,
                        dark: .palette.dark800
                    )
                )
        )
    }
}

struct PromoCard_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PromoCard(
                title: "Welcome to Blockchain!",
                message: "This is your Portfolio view. Once you own and hold crypto, the balances display here.",
                icon: Icon.blockchain
            ) {}
                .previewLayout(.sizeThatFits)

            PromoCard(
                title: "Welcome to Blockchain!",
                message: "This is your Portfolio view. Once you own and hold crypto, the balances display here.",
                icon: Icon.blockchain
            ) {}
                .previewLayout(.sizeThatFits)
                .colorScheme(.dark)

            PromoCard(
                title: "Notify Me",
                message: "Get a notification when Uniswap is available to trade on Blockchain.com.",
                icon: Icon.notificationOn,
                control: Control(title: "Notify Me", action: {})
            ) {}
                .previewLayout(.sizeThatFits)

            PromoCard(
                title: "Notify Me",
                message: "Get a notification when Uniswap is available to trade on Blockchain.com.",
                icon: Icon.notificationOn,
                control: Control(title: "Notify Me", action: {})
            ) {}
                .previewLayout(.sizeThatFits)
                .colorScheme(.dark)
        }
        .frame(width: 375)
    }
}
