// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// AlertCard from the Figma Component Library.
///
/// # Figma
///
/// [AlertCard](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=212%3A6021)
public struct AlertCard<Footer: View>: View {

    private let title: String
    private let message: String
    private let variant: AlertCardVariant
    private let isBordered: Bool
    private let footer: Footer
    private let backgroundColor: Color
    private let onCloseTapped: (() -> Void)?

    /// Create an AlertCard view
    /// - Parameters:
    ///   - title: Text displayed in the card as a title
    ///   - message: Main text displayed on the card
    ///   - variant: Color variant. See `extension AlertCard.Variant` below for options.
    ///   - isBordered: Option to add a colored border to the card
    ///   - onCloseTapped: Closure executed when the user types the close icon. This value
    ///   is optional. If not provided you will not see a close button on the view.
    public init(
        title: String,
        message: String,
        variant: AlertCardVariant = .default,
        isBordered: Bool = false,
        backgroundColor: Color = Color.semantic.light,
        @ViewBuilder footer: () -> Footer,
        onCloseTapped: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.variant = variant
        self.isBordered = isBordered
        self.backgroundColor = backgroundColor
        self.footer = footer()
        self.onCloseTapped = onCloseTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .typography(.paragraph2)
                    .foregroundColor(variant.titleColor)
                Spacer()
                if let onCloseTapped {
                    Button(
                        action: onCloseTapped,
                        label: {
                            Icon.closev2
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
            Text(rich: message)
                .typography(.caption1)
                .foregroundColor(.semantic.title)
            footer
        }
        .padding(Spacing.padding2)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(variant.borderColor, lineWidth: isBordered ? 1 : 0)
        )
    }
}

/// Style variant for AlertCard
public struct AlertCardVariant {
    let titleColor: Color
    let borderColor: Color

    public init(titleColor: Color, borderColor: Color) {
        self.titleColor = titleColor
        self.borderColor = borderColor
    }
}

extension AlertCard where Footer == EmptyView {

    public init(
        title: String,
        message: String,
        variant: AlertCardVariant = .default,
        isBordered: Bool = false,
        backgroundColor: Color = Color.semantic.light,
        onCloseTapped: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            message: message,
            variant: variant,
            isBordered: isBordered,
            backgroundColor: backgroundColor,
            footer: EmptyView.init,
            onCloseTapped: onCloseTapped
        )
    }
}

extension AlertCardVariant {

    public static let `default` = AlertCardVariant(
        titleColor: .semantic.title,
        borderColor: Color(
            light: .palette.grey300,
            dark: .palette.dark600
        )
    )

    // success
    public static let success = AlertCardVariant(
        titleColor: .semantic.success,
        borderColor: .semantic.success
    )

    // warning
    public static let warning = AlertCardVariant(
        titleColor: .semantic.warning,
        borderColor: .semantic.warning
    )

    // error
    public static let error = AlertCardVariant(
        titleColor: .semantic.error,
        borderColor: .semantic.error
    )
}

struct AlertCard_Previews: PreviewProvider {

    private static var message: String {
        "Card alert copy that directs the user to take an action or let’s them know what happened."
    }

    static var previews: some View {
        Group {
            preview(title: "Default", variant: .default)

            preview(title: "Success", variant: .success)

            preview(title: "Warning", variant: .warning)

            preview(title: "Error", variant: .error)
        }
        .padding()
    }

    @ViewBuilder private static func preview(title: String, variant: AlertCardVariant) -> some View {
        VStack {
            AlertCard(
                title: title,
                message: message,
                variant: variant,
                onCloseTapped: {}
            )
            AlertCard(
                title: title,
                message: message,
                variant: variant,
                onCloseTapped: {}
            )
            .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName(title)

        VStack {
            AlertCard(
                title: "\(title) Bordered",
                message: message,
                variant: variant,
                isBordered: true,
                onCloseTapped: {}
            )
            AlertCard(
                title: "\(title) Bordered",
                message: message,
                variant: variant,
                isBordered: true,
                onCloseTapped: {}
            )
            .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("\(title) Bordered")
    }
}
