// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// AlertToast from the Figma Component Library.
///
/// # Figma
///
/// [AlertToast](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=212%3A5937)
public struct AlertToast: View {

    private let text: String
    private let variant: Variant
    private var icon: Icon?

    /// Create an AlertToast view
    /// - Parameters:
    ///   - text: Text displayed in the toast
    ///   - variant: Color variant. See `extension AlertToast.Variant` below for options.
    ///   - icon: Optional Icon to be displayed on the leading of the toast
    public init(
        text: String,
        variant: Variant = .default,
        icon: Icon? = nil
    ) {
        self.text = text
        self.variant = variant
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let icon {
                icon
                    .color(variant.iconColor)
                    .frame(width: 16, height: 16)
            }
            Text(text)
                .typography(.body2)
                .foregroundColor(variant.textColor)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: Spacing.roundedBorderRadius(for: proxy.size.height))
                    .fill(variant.backgroundColor)
                    .shadow(
                        color: Color(
                            light: .palette.black.opacity(0.04),
                            dark: .palette.black.opacity(0.04)
                        ),
                        radius: 1,
                        x: 0,
                        y: 3
                    )
                    .shadow(
                        color: Color(
                            light: .palette.black.opacity(0.12),
                            dark: .palette.black.opacity(0.12)
                        ),
                        radius: 8,
                        x: 0,
                        y: 3
                    )
            }
        )
    }

    /// Style variant for AlertToast
    public struct Variant {
        fileprivate let backgroundColor: Color
        fileprivate let textColor: Color
        fileprivate let iconColor: Color
    }
}

extension AlertToast.Variant {
    public static let `default` = AlertToast.Variant(
        backgroundColor: .init(light: .palette.dark800, dark: .palette.grey300),
        textColor: .init(light: .palette.white, dark: .palette.grey900),
        iconColor: .init(light: .palette.white, dark: .palette.grey900)
    )

    // success
    public static let success = AlertToast.Variant(
        backgroundColor: .init(light: .palette.dark800, dark: .palette.green600),
        textColor: .init(light: .palette.green400, dark: .palette.white),
        iconColor: .init(light: .palette.green400, dark: .palette.white)
    )

    // warning
    public static let warning = AlertToast.Variant(
        backgroundColor: .init(light: .palette.dark800, dark: .palette.orange400),
        textColor: .init(light: .palette.orange400, dark: .palette.dark800),
        iconColor: .init(light: .palette.orange400, dark: .palette.dark800)
    )

    // error
    public static let error = AlertToast.Variant(
        backgroundColor: .init(light: .palette.dark800, dark: .palette.red600),
        textColor: .init(light: .palette.red400, dark: .palette.white),
        iconColor: .init(light: .palette.red400, dark: .palette.white)
    )
}

struct AlertToast_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                AlertToast(text: "Default", variant: .default)
                AlertToast(text: "Default", variant: .default)
                    .colorScheme(.dark)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Default")

            VStack {
                AlertToast(text: "Default", variant: .default, icon: .refresh)
                AlertToast(text: "Default", variant: .default, icon: .refresh)
                    .colorScheme(.dark)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Default + Icon")

            VStack {
                AlertToast(text: "Success", variant: .success)
                AlertToast(text: "Success", variant: .success)
                    .colorScheme(.dark)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Success")

            VStack {
                AlertToast(text: "Success", variant: .success, icon: .checkCircle)
                AlertToast(text: "Success", variant: .success, icon: .checkCircle)
                    .colorScheme(.dark)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Success + Icon")

            VStack {
                AlertToast(text: "Warning", variant: .warning)
                AlertToast(text: "Warning", variant: .warning)
                    .colorScheme(.dark)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Warning")

            VStack {
                AlertToast(text: "Warning", variant: .warning, icon: .alert)
                AlertToast(text: "Warning", variant: .warning, icon: .alert)
                    .colorScheme(.dark)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Warning + Icon")

            VStack {
                AlertToast(text: "Error", variant: .error)
                AlertToast(text: "Error", variant: .error)
                    .colorScheme(.dark)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Error")

            VStack {
                AlertToast(text: "Error", variant: .error, icon: .error)
                AlertToast(text: "Error", variant: .error, icon: .error)
                    .colorScheme(.dark)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Error + Icon")
        }
        .padding()
    }
}
