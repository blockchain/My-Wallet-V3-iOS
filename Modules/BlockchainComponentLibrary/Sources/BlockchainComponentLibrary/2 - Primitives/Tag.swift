// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Contained text used for informational data such as dates or warnings.
///
/// # Figma
///
/// [TagView](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=212%3A5974)
public struct TagView: View, Hashable {

    private let text: String
    private let variant: Variant
    private let icon: Icon?
    private let size: Size
    private let foregroundColor: Color?

    /// Create a tag view
    /// - Parameters:
    ///   - text: Text displayed in the tag
    ///   - variant: Color variant. See `extension TagView.Variant` below for options.
    public init(
        text: String,
        icon: Icon? = nil,
        variant: Variant = .default,
        size: Size = .small,
        foregroundColor: Color? = nil
    ) {
        self.text = text
        self.icon = icon
        self.variant = variant
        self.size = size
        self.foregroundColor = foregroundColor
    }

    public var body: some View {
        HStack(spacing: Spacing.padding1) {
            icon?
                .color(foregroundColor ?? variant.textColor)
                .frame(width: 16, height: 16)

            Text(text)
                .typography(size.typography)
                .foregroundColor(foregroundColor ?? variant.textColor)
        }
        .padding(size.padding)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(variant.backgroundColor)
        )
    }

    /// Style variant for TagView
    public struct Variant: Hashable {
        fileprivate let backgroundColor: Color
        fileprivate let textColor: Color
    }

    /// Size variant for TagView
    public struct Size: Hashable {
        fileprivate let typography: Typography
        fileprivate let padding: EdgeInsets
    }
}

extension EdgeInsets: Hashable {

    public static var zero: Self {
        EdgeInsets()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(leading)
        hasher.combine(trailing)
        hasher.combine(bottom)
    }

    public var vertical: CGFloat { top + bottom }
    public var horizontal: CGFloat { leading + trailing }

    public static func - (lhs: CGRect, rhs: EdgeInsets) -> CGRect {
        lhs + -rhs
    }

    public static func + (lhs: CGRect, rhs: EdgeInsets) -> CGRect {
        let x: CGFloat
        var width = lhs.width + rhs.horizontal
        if width < 0 {
            width = 0
            x = lhs.minX + (rhs.leading * lhs.width) / rhs.horizontal
        } else {
            x = lhs.minX - rhs.leading
        }
        let y: CGFloat
        var height = lhs.height + rhs.vertical
        let off = rhs.top
        if height < 0 {
            height = 0
            y = lhs.minY + (off * lhs.height) / rhs.vertical
        } else {
            y = lhs.minY - off
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension TagView.Size {

    /// .caption2, padding 8x4
    public static let small = Self(
        typography: .caption2,
        padding: EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
    )

    /// .paragraph2, padding 12x6
    public static let large = Self(
        typography: .paragraph2,
        padding: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
    )
}

extension TagView.Variant {

    /// default
    public static let `default` = TagView.Variant(
        backgroundColor: .init(light: .semantic.light, dark: .palette.dark600),
        textColor: .init(light: .semantic.title, dark: .semantic.title)
    )

    /// infoalt
    public static let infoAlt = TagView.Variant(
        backgroundColor: .init(light: .palette.blue000, dark: .palette.dark600),
        textColor: .init(light: .semantic.primary, dark: .semantic.primary)
    )

    /// success
    public static let success = TagView.Variant(
        backgroundColor: .init(light: .palette.green100, dark: .semantic.success),
        textColor: .init(light: .semantic.success, dark: .palette.dark900)
    )

    /// warning
    public static let warning = TagView.Variant(
        backgroundColor: .init(light: .palette.orange100, dark: .semantic.warning),
        textColor: .init(light: .palette.orange600, dark: .palette.dark900)
    )

    /// error
    public static let error = TagView.Variant(
        backgroundColor: .init(light: .palette.red100, dark: .semantic.error),
        textColor: .init(light: .semantic.error, dark: .palette.dark900)
    )
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TagView(text: "Informational")

            TagView(text: "Informational")
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Default")

        VStack {
            TagView(text: "Informational", size: .large)

            TagView(text: "Informational", size: .large)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Default Large")

        VStack {
            TagView(text: "Info Alt", variant: .infoAlt)

            TagView(text: "Info Alt", variant: .infoAlt)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("InfoAlt")

        VStack {
            TagView(text: "Info Alt", variant: .infoAlt, size: .large)

            TagView(text: "Info Alt", variant: .infoAlt, size: .large)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("InfoAlt Large")

        VStack {
            TagView(text: "Success", variant: .success)

            TagView(text: "Success", variant: .success)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Success")

        VStack {
            TagView(text: "Success", variant: .success, size: .large)

            TagView(text: "Success", variant: .success, size: .large)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Success Large")

        VStack {
            TagView(text: "Warning", variant: .warning)

            TagView(text: "Warning", variant: .warning)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Warning")

        VStack {
            TagView(text: "Warning", variant: .warning, size: .large)

            TagView(text: "Warning", variant: .warning, size: .large)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Warning Large")

        VStack {
            TagView(text: "Error", variant: .error)

            TagView(text: "Error", variant: .error)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Error")

        VStack {
            TagView(text: "Error", variant: .error, size: .large)

            TagView(text: "Error", variant: .error, size: .large)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Error Large")
    }
}
