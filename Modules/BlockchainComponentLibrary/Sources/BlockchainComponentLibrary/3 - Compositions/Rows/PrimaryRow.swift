// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// PrimaryRow from the Figma Component Library.
///
///
/// # Usage:
///
/// Only title is mandatory to create a Row. Rest of parameters are optional. When no trailing accessory view es provided, a chevron view is shown
/// ```
/// PrimaryRow(
///     title: "Link a Bank",
///     subtitle: "Instant Connection",
///     description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
///     tags: [
///         TagView(text: "Fastest", variant: .success),
///         TagView(text: "Warning Alert", variant: .warning)
///     ],
///     isSelected: $selection {
///         Icon.bank
///             .fixedSize()
///     } trailing: {
///         Switch()
///     }
///
/// ```
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Table Rows](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11163)

public struct PrimaryRowTextValue {
    public let text: String
    public let highlightRanges: [Range<String.Index>]

    public init(
        text: String,
        highlightRanges: [Range<String.Index>] = []
    ) {
        self.text = text
        self.highlightRanges = highlightRanges
    }
}

public struct PrimaryRowTextStyle {
    let title: Typography
    let subtitle: Typography
    let caption: Typography
    let description: Typography

    public static var superApp = PrimaryRowTextStyle(
        title: .paragraph2,
        subtitle: .paragraph2
    )

    public init(
        title: Typography = .body2,
        subtitle: Typography = .paragraph1,
        caption: Typography = .caption1,
        description: Typography = .caption1
    ) {
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.description = description
    }
}

public struct PrimaryRow<Leading: View, Trailing: View>: View {

    public typealias TextValue = PrimaryRowTextValue

    private let title: TextValue
    private let caption: String?
    private let subtitle: TextValue?
    private let description: String?
    private let tags: [TagView]
    private let leading: Leading
    private let trailing: Trailing

    private let action: (() -> Void)?
    private let highlight: Bool
    private let textStyle: PrimaryRowTextStyle
    private let isSelectable: Bool

    /// Create a default row with the given data.
    ///
    /// Only Title is mandatory, rest of the parameters are optional and the row will form itself depending on the given data
    /// - Parameters:
    ///   - title: Title of the row
    ///   - caption: Optional text shown on top of the title
    ///   - subtitle: Optional subtitle on the main vertical content view
    ///   - description: Optional description text on the main vertical content view
    ///   - tags: Optional array of tags object. They show up on the bottom part of the main vertical content view, and align themself horizontally
    ///   - isSelected: Binding for the selection state
    ///   - leading: Optional view on the leading part of the row.
    ///   - trailing: Optional view on the trailing part of the row. If no view is provided, a chevron icon is added automatically.
    public init(
        title: String,
        caption: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [TagView] = [],
        highlight: Bool = true,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing,
        action: (() -> Void)? = nil,
        textStyle: PrimaryRowTextStyle = .init()
    ) {
        self.title = .init(text: title)
        self.caption = caption
        self.subtitle = subtitle.map { .init(text: $0) }
        self.description = description
        self.tags = tags
        self.highlight = highlight
        self.isSelectable = action != nil
        self.leading = leading()
        self.trailing = trailing()
        self.action = action
        self.textStyle = textStyle
    }

    public init(
        title: TextValue,
        caption: String? = nil,
        subtitle: TextValue? = nil,
        description: String? = nil,
        tags: [TagView] = [],
        highlight: Bool = true,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing,
        action: (() -> Void)? = nil,
        textStyle: PrimaryRowTextStyle = .init()
    ) {
        self.title = title
        self.caption = caption
        self.subtitle = subtitle
        self.description = description
        self.tags = tags
        self.highlight = highlight
        self.isSelectable = action != nil
        self.leading = leading()
        self.trailing = trailing()
        self.action = action
        self.textStyle = textStyle
    }

    public var body: some View {
        if isSelectable {
            Button {
                action?()
            } label: {
                horizontalContent
            }
            .buttonStyle(
                PrimaryRowStyle(isSelectable: highlight && isSelectable)
            )
        } else {
            horizontalContent
                .background(Color.semantic.background)
                .accessibilityElement(children: .combine)
        }
    }

    var horizontalContent: some View {
        HStack(alignment: .customRowVerticalAlignment, spacing: 0) {
            leading
                .padding(.trailing, Spacing.padding2)
            mainContent
                .padding(.vertical, Spacing.padding2)
            Spacer()
            trailing
                .padding(.leading, Spacing.padding2)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.padding3)
    }

    @ViewBuilder var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                if let caption {
                    Text(caption)
                        .typography(textStyle.caption)
                        .foregroundColor(.semantic.body)
                }

                textView(
                    text: title,
                    textTypography: textStyle.title,
                    textColor: .semantic.title,
                    textColorWhenHighlightighed: .semantic.title,
                    textColorWhenNotHighlightighed: Color(
                        light: .palette.grey600,
                        dark: .palette.dark200
                    )
                )

                if let subtitle {
                    textView(
                        text: subtitle,
                        textTypography: textStyle.subtitle,
                        textColor: Color(
                            light: .palette.grey600,
                            dark: .palette.dark200
                        ),
                        textColorWhenHighlightighed: .semantic.title,
                        textColorWhenNotHighlightighed: Color(
                            light: .palette.grey600,
                            dark: .palette.dark200
                        )
                    )
                }
            }
            .alignmentGuide(.customRowVerticalAlignment) {
                $0[VerticalAlignment.center]
            }
            if let description {
                Text(description)
                    .typography(textStyle.description)
                    .foregroundColor(
                        Color(
                            light: .palette.grey600,
                            dark: .palette.dark200
                        )
                    )
                    .padding(.top, 11)
            }
            if !tags.isEmpty {
                HStack {
                    ForEach(tags, id: \.self) { view in
                        view
                    }
                }
                .padding(.top, 10)
            }
        }
    }

    private func textView(
        text: TextValue,
        textTypography: Typography,
        textColor: Color,
        textColorWhenHighlightighed: Color,
        textColorWhenNotHighlightighed: Color
    ) -> some View {
        if #available(iOS 15.0, *), #available(macOS 12.0, *) {
            return Text(text.text) { string in
                string.font = textTypography.font
                guard !text.highlightRanges.isEmpty else {
                    return string.foregroundColor = textColor
                }

                string.foregroundColor = textColorWhenNotHighlightighed
                var atLeastOneRangeIsHighlighted = false
                text.highlightRanges.forEach { range in
                    if let lowerBound = AttributedString.Index(range.lowerBound, within: string),
                       let upperBound = AttributedString.Index(range.upperBound, within: string)
                    {
                        let rangeString = Range<AttributedString.Index>.init(uncheckedBounds: (lower: lowerBound, upper: upperBound))
                        string[rangeString].foregroundColor = textColorWhenHighlightighed
                        atLeastOneRangeIsHighlighted = true
                    }
                }
                if !atLeastOneRangeIsHighlighted {
                    string.foregroundColor = textColor
                }
            }
        } else {
            return Text(text.text)
                .typography(textTypography)
                .foregroundColor(textColor)
        }
    }
}

private struct PrimaryRowStyle: ButtonStyle {

    let isSelectable: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed && isSelectable ? Color.semantic.light : Color.semantic.background)
    }
}

extension PrimaryRow where Leading == EmptyView {

    /// Initialize a PrimaryRow with no leading view
    /// - Parameters:
    ///   - title: Leading title text
    ///   - subtitle: Optional leading subtitle text
    ///   - description: Optional leading description
    ///   - tags: Optional TagViews displayed at the bottom of the row.
    ///   - isSelected: Binding for the selection state
    ///   - trailing: Optional view displayed at the trailing edge.
    public init(
        title: String,
        caption: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        textStyle: PrimaryRowTextStyle = .init(),
        tags: [TagView] = [],
        @ViewBuilder trailing: () -> Trailing,
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            caption: caption,
            subtitle: subtitle,
            description: description,
            tags: tags,
            leading: { EmptyView() },
            trailing: trailing,
            action: action,
            textStyle: textStyle
        )
    }

    /// Initialize a PrimaryRow with no leading view, and default trailing chevron
    /// - Parameters:
    ///   - title: Leading title text
    ///   - subtitle: Optional leading subtitle text
    ///   - description: Optional leading description
    ///   - tags: Optional TagViews displayed at the bottom of the row.
    ///   - isSelected: Binding for the selection state
    public init(
        title: TextValue,
        caption: String? = nil,
        subtitle: TextValue? = nil,
        description: String? = nil,
        textStyle: PrimaryRowTextStyle = .init(),
        tags: [TagView] = [],
        @ViewBuilder trailing: () -> Trailing,
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            caption: caption,
            subtitle: subtitle,
            description: description,
            tags: tags,
            leading: { EmptyView() },
            trailing: trailing,
            action: action,
            textStyle: textStyle
        )
    }
}

extension PrimaryRow where Trailing == ChevronRight {

    /// Initialize a PrimaryRow with default trailing chevron
    /// - Parameters:
    ///   - title: Leading title text
    ///   - subtitle: Optional leading subtitle text
    ///   - description: Optional leading description
    ///   - tags: Optional TagViews displayed at the bottom of the row.
    ///   - isSelected: Binding for the selection state
    ///   - leading: View displayed at the leading edge.
    public init(
        title: String,
        caption: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        textStyle: PrimaryRowTextStyle = .init(),
        tags: [TagView] = [],
        @ViewBuilder leading: () -> Leading,
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            caption: caption,
            subtitle: subtitle,
            description: description,
            tags: tags,
            leading: leading,
            trailing: { ChevronRight() },
            action: action,
            textStyle: textStyle
        )
    }
}

extension PrimaryRow where Leading == EmptyView, Trailing == ChevronRight {

    /// Initialize a PrimaryRow with no leading view, and default trailing chevron
    /// - Parameters:
    ///   - title: Leading title text
    ///   - subtitle: Optional leading subtitle text
    ///   - description: Optional leading description
    ///   - tags: Optional TagViews displayed at the bottom of the row.
    ///   - isSelected: Binding for the selection state
    public init(
        title: String,
        caption: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        textStyle: PrimaryRowTextStyle = .init(),
        tags: [TagView] = [],
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            caption: caption,
            subtitle: subtitle,
            description: description,
            tags: tags,
            leading: { EmptyView() },
            trailing: { ChevronRight() },
            action: action,
            textStyle: textStyle
        )
    }
}

/// View containing Icon.chevronRight, colored for table rows.
public struct ChevronRight: View {
    public var body: some View {
        Icon.chevronRight
            .color(
                Color(
                    light: .palette.grey400,
                    dark: .palette.grey400
                )
            )
            .fixedSize()
            .flipsForRightToLeftLayoutDirection(true)
    }
}

extension VerticalAlignment {
    struct CustomRowVerticalAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    static let customRowVerticalAlignment = VerticalAlignment(CustomRowVerticalAlignment.self)
}

struct PrimaryRow_Previews: PreviewProvider {

    static var previews: some View {
        PreviewController(selection: 0)
            .previewLayout(.sizeThatFits)
    }

    struct PreviewController: View {

        @State var selection: Int

        init(selection: Int) {
            _selection = State(initialValue: selection)
        }

        var body: some View {
            Group {
                PrimaryRow(
                    title: "Trading",
                    subtitle: "Buy & Sell",
                    action: {
                        selection = 0
                    }
                )
                PrimaryRow(
                    title: "Email Address",
                    subtitle: "satoshi@blockchain.com",
                    tags: [TagView(text: "Confirmed", variant: .success)],
                    action: {
                        selection = 1
                    }
                )
                PrimaryRow(
                    title: "From: BTC Blockchain.com Account",
                    subtitle: "To: 0x093871209487120934812027675",
                    action: {
                        selection = 2
                    }
                )
            }
            .frame(width: 375)
            Group {
                PrimaryRow(
                    title: "Link a Bank",
                    subtitle: "Instant Connection",
                    description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                    tags: [
                        TagView(text: "Fastest", variant: .success),
                        TagView(text: "Warning Alert", variant: .warning)
                    ],
                    action: {
                        selection = 3
                    }
                )
                PrimaryRow(
                    title: "Cloud Backup",
                    subtitle: "Buy & Sell",
                    trailing: {
                        Switch()
                    }
                )
                PrimaryRow(
                    title: "Features and Limits",
                    action: {
                        selection = 5
                    }
                )
            }
            .frame(width: 375)
            Group {
                PrimaryRow(
                    title: "Back Up Your Wallet",
                    subtitle: "Step 1",
                    leading: {
                        Icon.wallet
                            .color(.semantic.dark)
                            .fixedSize()
                    },
                    action: {
                        selection = 6
                    }
                )
                PrimaryRow(
                    title: "Gold Level",
                    subtitle: "Higher Trading Limits",
                    tags: [TagView(text: "Approved", variant: .success)],
                    leading: {
                        Icon.apple
                            .color(.semantic.orangeBG)
                            .fixedSize()
                    },
                    action: {
                        selection = 7
                    }
                )
                PrimaryRow(
                    title: "Trade",
                    subtitle: "BTC -> ETH",
                    leading: {
                        Icon.trade
                            .color(.semantic.success)
                            .fixedSize()
                    },
                    action: {
                        selection = 8
                    }
                )
                PrimaryRow(
                    title: "Link a Bank",
                    subtitle: "Instant Connection",
                    description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                    tags: [
                        TagView(text: "Fastest", variant: .success),
                        TagView(text: "Warning Alert", variant: .warning)
                    ],
                    leading: {
                        Icon.bank
                            .color(.semantic.primary)
                            .fixedSize()
                    },
                    action: {
                        selection = 9
                    }
                )
                PrimaryRow(
                    title: "Features and Limits",
                    leading: {
                        Icon.blockchain
                            .color(.semantic.primary)
                            .fixedSize()
                    },
                    action: {
                        selection = 10
                    }
                )
            }
            .frame(width: 375)
        }
    }

    struct Switch: View {
        @State var isOn: Bool = false

        var body: some View {
            PrimarySwitch(
                variant: .green,
                accessibilityLabel: "Test",
                isOn: $isOn
            )
        }
    }
}

/// extension to make applying AttributedString even easier
extension Text {
    fileprivate init(_ string: String, configure: (inout AttributedString) -> Void) {
        var attributedString = AttributedString(string)
        configure(&attributedString)
        self.init(attributedString)
    }
}
