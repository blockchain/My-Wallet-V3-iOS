// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// BalanceRow from the Figma Component Library.
///
///
/// # Usage:
///
/// The actual final layout of this cell depends on the parameters assigned on initialization.
/// LeadingSubtitle, TrailingDescriptionColor and graph are optional parameters
/// ```
/// SimpleBalanceRow(
///     leadingTitle: "Blockchain.com Account",
///     leadingDescription: "Bitcoin",
///     trailingTitle: "$7,926.43",
///     trailingDescription: "0.00039387 BTC",
///     tags: [
///         TagView(text: "No Fees", variant: .success),
///         TagView(text: "Faster", variant: .success),
///         TagView(text: "Warning Alert", variant: .warning)
///     ],
///     isSelected: Binding(
///         get: {
///             selection == 0
///         },
///         set: { _ in
///             selection = 0
///         }
///     )
/// ) {
///     Icon.trade
///         .fixedSize()
///         .color(.semantic.primary)
/// }
///
/// ```
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Table Rows](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11163)

public struct SimpleBalanceRow<Leading: View>: View {

    private let leading: Leading
    private let leadingTitle: String
    private let leadingDescription: String?
    private let trailingTitle: String?
    private let trailingDescription: String?
    private let trailingDescriptionColor: Color
    private let inlineTagView: TagView?
    private let tags: [TagView]
    private let mainContentSpacing: CGFloat = 6

    @Binding private var isSelected: Bool
    private let isSelectable: Bool
    let action: () -> Void

    /// Create a Balance Row with the given data.
    ///
    /// LeadingSubtitle, TrailingDescriptionColor and graph are optional parameters and the row will form itself depending on the given data.
    /// The position of some views inside the row will vary depending on the data present.
    ///
    /// - Parameters:
    ///   - leadingTitle: Title on the leading side of the row
    ///   - leadingDescription: Description string on the leading side of the row
    ///   - trailingTitle: Title on the trailing side of the row
    ///   - trailingDescription: Description string on the trailing side of the row view
    ///   - trailingDescriptionColor: Optional color for the trailingDescription text
    ///   - inlineTagView: Optional tag shown at the right of the leading description text
    ///   - tags: Optional array of tags object. They show up on the bottom part of the main vertical content view, and align themself horizontally
    ///   - isSelected: Binding for the selection state
    ///   - leading: View on the leading side of the row.
    ///
    public init(
        leadingTitle: String,
        leadingDescription: String? = nil,
        trailingTitle: String? = nil,
        trailingDescription: String?,
        trailingDescriptionColor: Color? = nil,
        inlineTagView: TagView? = nil,
        tags: [TagView] = [],
        isSelected: Binding<Bool>? = nil,
        action: @escaping () -> Void = {},
        @ViewBuilder leading: () -> Leading
    ) {
        self.leadingTitle = leadingTitle
        self.leadingDescription = leadingDescription
        self.trailingTitle = trailingTitle
        self.trailingDescription = trailingDescription
        self.trailingDescriptionColor = trailingDescriptionColor ?? Color.WalletSemantic.body
        self.inlineTagView = inlineTagView
        self.tags = tags
        self.isSelectable = isSelected != nil
        _isSelected = isSelected ?? .constant(false)
        self.action = action
        self.leading = leading()
    }

    public var body: some View {
        Button {
            isSelected = true
            action()
        } label: {
            HStack(alignment: .customRowVerticalAlignment, spacing: 16) {
                leading
                VStack(alignment: .leading, spacing: 8) {
                    mainContent()
                    if !tags.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { view in
                                view
                            }
                        }
                    }
                }
            }
        }
        .buttonStyle(SimpleBalanceRowStyle(isSelectable: isSelectable))
    }

    @ViewBuilder private var leadingTitleView: some View {
        Text(leadingTitle)
            .typography(.paragraph2)
            .foregroundColor(Color.WalletSemantic.title)
    }

    @ViewBuilder private var leadingDescriptionView: some View {
        if let leadingDescription {
           HStack(spacing: 8) {
                Text(leadingDescription)
                    .typography(.paragraph2)
                    .foregroundColor(Color.WalletSemantic.title)

                if let tag = inlineTagView {
                    tag
                }
           }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private var trailingTitleView: some View {
        if let trailingTitle {
            Text(trailingTitle)
                .typography(.paragraph2)
                .foregroundColor(.semantic.title)
        }
    }

    @ViewBuilder private var trailingDescriptionView: some View {
        if let trailingDescription {
            Text(trailingDescription)
                .typography(.caption1)
                .foregroundColor(trailingDescriptionColor)
        }
    }

    @ViewBuilder private func mainContent() -> some View {
        if leadingDescription == nil {
            defaultContentNoLeadingDescription()
        } else if trailingDescription == nil {
            defaultContentNoTrailingDescription()
        } else {
            defaultContent()
        }
    }

    @ViewBuilder private func defaultContentNoTrailingDescription() -> some View {
        pair(
            leadingTitleView,
            VStack(
                alignment: .trailing,
                spacing: mainContentSpacing
            ) {
                trailingTitleView
            }.alignmentGuide(.customRowVerticalAlignment) {
                $0[VerticalAlignment.center]
            }
        )
    }

    @ViewBuilder private func defaultContentNoLeadingDescription() -> some View {
        pair(
            leadingTitleView,
            VStack(
                alignment: .trailing,
                spacing: mainContentSpacing
            ) {
                trailingTitleView
                trailingDescriptionView
            }.alignmentGuide(.customRowVerticalAlignment) {
                $0[VerticalAlignment.center]
            }
        )
    }

    @ViewBuilder private func defaultContent() -> some View {
            VStack(spacing: mainContentSpacing) {
                pair(leadingTitleView, trailingTitleView)
                pair(leadingDescriptionView, trailingDescriptionView)
            }
            .alignmentGuide(.customRowVerticalAlignment) {
                $0[VerticalAlignment.center]
            }
    }

    @ViewBuilder private func pair(
        _ leading: some View,
        _ trailing: some View
    ) -> some View {
        HStack {
            leading
            Spacer()
            trailing
        }
    }
}

private struct SimpleBalanceRowStyle: ButtonStyle {

    let isSelectable: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.padding3)
            .padding(.vertical, Spacing.padding2)
            .background(configuration.isPressed && isSelectable ? Color.semantic.light : Color.semantic.background)
    }
}

struct SimpleBalanceRow_Previews: PreviewProvider {

    static var previews: some View {
        PreviewController(selection: 0)
            .frame(width: 375)
            .previewLayout(.sizeThatFits)
    }

    struct PreviewController: View {

        @State var selection: Int

        init(selection: Int) {
            _selection = State(initialValue: selection)
        }

        var body: some View {
            Group {
                ScrollView {
                    SimpleBalanceRow(
                        leadingTitle: "Bitcoin",
                        leadingDescription: "BTC",
                        trailingTitle: "$44,403.13",
                        trailingDescription: "↓ 12.32%",
                        trailingDescriptionColor: .semantic.error,
                        isSelected: Binding(
                            get: {
                                selection == 0
                            },
                            set: { _ in
                                selection = 0
                            }
                        )
                    ) {
                        Icon.trade
                            .color(.semantic.warning)
                            .fixedSize()
                    }

                    SimpleBalanceRow(
                        leadingTitle: "Bitcoin",
                        trailingTitle: "$44,403.13",
                        trailingDescription: "↓ 12.32%",
                        trailingDescriptionColor: .semantic.error,
                        isSelected: Binding(
                            get: {
                                selection == 0
                            },
                            set: { _ in
                                selection = 0
                            }
                        )
                    ) {
                        Icon.trade
                            .color(.semantic.warning)
                            .fixedSize()
                    }

                    SimpleBalanceRow(
                        leadingTitle: "Bitcoin",
                        trailingTitle: "$44,403.13",
                        trailingDescription: nil,
                        trailingDescriptionColor: .semantic.error,
                        isSelected: Binding(
                            get: {
                                selection == 0
                            },
                            set: { _ in
                                selection = 0
                            }
                        )
                    ) {
                        Icon.trade
                            .color(.semantic.warning)
                            .fixedSize()
                    }

                    SimpleBalanceRow(
                        leadingTitle: "Blockchain.com Account",
                        leadingDescription: "Bitcoin",
                        trailingTitle: "$7,926.43",
                        trailingDescription: "0.00039387 BTC",
                        tags: [
                            TagView(text: "No Fees", variant: .success),
                            TagView(text: "Faster", variant: .success),
                            TagView(text: "Warning Alert", variant: .warning)
                        ],
                        isSelected: Binding(
                            get: {
                                selection == 1
                            },
                            set: { _ in
                                selection = 1
                            }
                        )
                    ) {
                        Icon.trade
                            .color(.semantic.primary)
                            .fixedSize()
                    }
                }
                .previewLayout(.sizeThatFits)
            }
        }
    }
}
