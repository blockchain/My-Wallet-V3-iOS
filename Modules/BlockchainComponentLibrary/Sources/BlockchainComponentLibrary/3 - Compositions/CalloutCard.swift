// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A container view that displays a callout for the user with a Call to Action
///
/// # Figma
///
/// [Navigation](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A7478)
public struct CalloutCard<Leading: View>: View {

    @ViewBuilder private let leading: () -> Leading
    private let title: String
    private let message: String
    private let control: Control

    public init(
        @ViewBuilder leading: @escaping () -> Leading,
        title: String,
        message: String,
        control: Control
    ) {
        self.leading = leading
        self.title = title
        self.message = message
        self.control = control
    }

    public var body: some View {
        HStack(alignment: .center, spacing: Spacing.padding2) {
            leading()
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: Spacing.baseline / 2) {
                Text(title)
                    .typography(.caption1)
                Text(message)
                    .typography(.paragraph2)
            }

            Spacer()

            SmallPrimaryButton(
                title: control.title,
                action: control.action
            )
        }
        .padding(Spacing.padding2)
        .background(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .fill(
                    Color(
                        light: .palette.white,
                        dark: .palette.dark800
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .stroke(Color.semantic.primary)
        )
    }
}

struct CalloutCard_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            CalloutCard(
                leading: {
                    Icon.moneyUSD
                },
                title: "Buy More Crypto",
                message: "Upgrade Your Wallet",
                control: .init(
                    title: "GO",
                    action: {}
                )
            )
        }
    }
}
