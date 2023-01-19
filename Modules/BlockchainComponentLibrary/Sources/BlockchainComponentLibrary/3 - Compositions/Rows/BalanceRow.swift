// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// BalanceRow from the Figma Component Library.
///
///
/// # Usage:
///
/// The actual final layout of this cell depends on the parameters assigned on initialization.
/// LeadingSubtitle, TrailingDescriptionColor and graph are optional parameters
/// ```
/// BalanceRow(
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

public struct BalanceRow<Leading: View, Graph: View>: View {

    private let leading: Leading
    private let leadingTitle: String
    private let leadingSubtitle: String?
    private let leadingDescription: String?
    private let graph: Graph?
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
    ///   - leadingSubtitle: Optional subtitle on the leading side of the row
    ///   - leadingDescription: Description string on the leading side of the row
    ///   - trailingTitle: Title on the trailing side of the row
    ///   - trailingDescription: Description string on the trailing side of the row view
    ///   - trailingDescriptionColor: Optional color for the trailingDescription text
    ///   - inlineTagView: Optional tag shown at the right of the leading description text
    ///   - tags: Optional array of tags object. They show up on the bottom part of the main vertical content view, and align themself horizontally
    ///   - isSelected: Binding for the selection state
    ///   - leading: View on the leading side of the row.
    ///   - graph: View on the trailing side of the row.
    public init(
        leadingTitle: String,
        leadingSubtitle: String? = nil,
        leadingDescription: String?,
        trailingTitle: String?,
        trailingDescription: String?,
        trailingDescriptionColor: Color? = nil,
        inlineTagView: TagView? = nil,
        tags: [TagView] = [],
        isSelected: Binding<Bool>? = nil,
        action: @escaping () -> Void = {},
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder graph: () -> Graph
    ) {
        self.leadingTitle = leadingTitle
        self.leadingSubtitle = leadingSubtitle
        self.leadingDescription = leadingDescription
        self.trailingTitle = trailingTitle
        self.trailingDescription = trailingDescription
        self.trailingDescriptionColor = trailingDescriptionColor ?? Color(
            light: .palette.grey600,
            dark: .palette.dark200
        )
        self.inlineTagView = inlineTagView
        self.tags = tags
        self.isSelectable = isSelected != nil
        _isSelected = isSelected ?? .constant(false)
        self.action = action
        self.leading = leading()
        self.graph = graph()
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
        .buttonStyle(BalanceRowStyle(isSelectable: isSelectable))
    }

    @ViewBuilder private var leadingTitleView: some View {
        Text(leadingTitle)
            .typography(.body2)
            .foregroundColor(.semantic.title)
    }

    @ViewBuilder private var leadingSubtitleView: some View {
        if let leadingSubtitle {
            Text(leadingSubtitle)
                .typography(.paragraph2)
                .foregroundColor(.semantic.title)
        }
    }

    @ViewBuilder private var leadingDescriptionView: some View {
        if let leadingDescription {
            HStack(spacing: 8) {
                Text(leadingDescription)
                    .typography(.paragraph1)
                    .foregroundColor(
                        Color(
                            light: .palette.grey600,
                            dark: .palette.dark200
                        )
                    )
                if let tag = inlineTagView {
                    tag
                }
            }
        }
    }

    @ViewBuilder private var trailingTitleView: some View {
        if let trailingTitle {
            if graph is EmptyView {
                Text(trailingTitle)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
            } else {
                Text(trailingTitle)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
        } else {
            Text("......").redacted(reason: .placeholder)
        }
    }

    @ViewBuilder private var trailingDescriptionView: some View {
        if let trailingDescription {
            Text(trailingDescription)
                .typography(.paragraph1)
                .foregroundColor(trailingDescriptionColor)
        } else {
            Text("......").redacted(reason: .placeholder)
        }
    }

    @ViewBuilder private func mainContent() -> some View {
        if leadingDescription == nil, graph is EmptyView {
            defaultContentNoLeadingDescription()
        } else if leadingSubtitle == nil, graph is EmptyView {
            defaultContent()
        } else if leadingSubtitle == nil, !(graph is EmptyView) {
            fullContentNoSubtitle()
        } else if graph is EmptyView {
            fullContentNoGraph()
        } else {
            fullContent()
        }
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

    @ViewBuilder private func fullContent() -> some View {
        VStack(spacing: mainContentSpacing) {
            VStack(spacing: mainContentSpacing) {
                pair(leadingTitleView, graph)
                pair(leadingSubtitleView, trailingTitleView)
            }
            .alignmentGuide(.customRowVerticalAlignment) {
                $0[VerticalAlignment.center]
            }
            pair(leadingDescriptionView, trailingDescriptionView)
        }
    }

    @ViewBuilder private func fullContentNoGraph() -> some View {
        VStack(spacing: mainContentSpacing) {
            VStack(spacing: mainContentSpacing) {
                pair(leadingTitleView, trailingTitleView)
                pair(leadingSubtitleView, trailingDescriptionView)
            }
            .alignmentGuide(.customRowVerticalAlignment) {
                $0[VerticalAlignment.center]
            }
            pair(leadingDescriptionView, Spacer())
        }
    }

    @ViewBuilder private func fullContentNoSubtitle() -> some View {
        VStack(spacing: mainContentSpacing) {
            VStack(spacing: mainContentSpacing) {
                pair(leadingTitleView, graph)
                pair(leadingDescriptionView, trailingTitleView)
            }
            .alignmentGuide(.customRowVerticalAlignment) {
                $0[VerticalAlignment.center]
            }
            pair(Spacer(), trailingDescriptionView)
        }
    }

    @ViewBuilder private func defaultContentNoLeadingDescription() -> some View {
        HStack(spacing: mainContentSpacing) {
            VStack(alignment: .leading, spacing: mainContentSpacing) {
                leadingTitleView
            }
            Spacer()
            VStack(alignment: .trailing, spacing: mainContentSpacing) {
                trailingTitleView
                trailingDescriptionView
            }
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

private struct BalanceRowStyle: ButtonStyle {

    let isSelectable: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.padding3)
            .padding(.vertical, Spacing.padding2)
            .background(configuration.isPressed && isSelectable ? Color.semantic.light : Color.semantic.background)
    }
}

extension BalanceRow where Graph == EmptyView {

    public init(
        leadingTitle: String,
        leadingSubtitle: String? = nil,
        leadingDescription: String?,
        trailingTitle: String?,
        trailingDescription: String?,
        trailingDescriptionColor: Color? = nil,
        inlineTagView: TagView? = nil,
        tags: [TagView] = [],
        isSelected: Binding<Bool>? = nil,
        action: @escaping () -> Void = {},
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(
            leadingTitle: leadingTitle,
            leadingSubtitle: leadingSubtitle,
            leadingDescription: leadingDescription,
            trailingTitle: trailingTitle,
            trailingDescription: trailingDescription,
            trailingDescriptionColor: trailingDescriptionColor,
            inlineTagView: inlineTagView,
            tags: tags,
            isSelected: isSelected,
            action: action,
            leading: leading
        ) {
            EmptyView()
        }
    }
}

struct BalanceRow_Previews: PreviewProvider {

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
                    BalanceRow(
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

                    BalanceRow(
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

                    BalanceRow(
                        leadingTitle: "Bitcoin",
                        leadingDescription: "BTC",
                        trailingTitle: "$44,403.13",
                        trailingDescription: "↓ 12.32%",
                        trailingDescriptionColor: .semantic.error,
                        inlineTagView: TagView(text: "Tradable", variant: .success),
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

                    BalanceRow(
                        leadingTitle: "BTC - USD",
                        leadingDescription: "Limit Buy - Open",
                        trailingTitle: "0.5736523 BTC",
                        trailingDescription: "$15,482.86",
                        isSelected: Binding(
                            get: {
                                selection == 2
                            },
                            set: { _ in
                                selection = 2
                            }
                        )
                    ) {
                        Icon.moneyUSD
                            .color(.semantic.warning)
                            .fixedSize()
                    }

                    BalanceRow(
                        leadingTitle: "Bitcoin",
                        leadingSubtitle: "$15,879.90",
                        leadingDescription: "0.3576301941 BTC",
                        trailingTitle: "$44,403.13",
                        trailingDescription: "↓ 12.32%",
                        trailingDescriptionColor: .semantic.error,
                        isSelected: Binding(
                            get: {
                                selection == 3
                            },
                            set: { _ in
                                selection = 3
                            }
                        ),
                        leading: {
                            Icon.trade
                                .color(.semantic.warning)
                                .fixedSize()
                        },
                        graph: {
                            graph
                        }
                    )

                    BalanceRow(
                        leadingTitle: "Bitcoin",
                        leadingDescription: "0.3576301941 BTC",
                        trailingTitle: "$44,403.13",
                        trailingDescription: "↓ 12.32%",
                        trailingDescriptionColor: .semantic.error,
                        isSelected: Binding(
                            get: {
                                selection == 4
                            },
                            set: { _ in
                                selection = 4
                            }
                        ),
                        leading: {
                            Icon.trade
                                .color(.semantic.warning)
                                .fixedSize()
                        },
                        graph: {
                            graph
                        }
                    )

                    BalanceRow(
                        leadingTitle: "Bitcoin",
                        leadingSubtitle: "$15,879.90",
                        leadingDescription: "0.3576301941 BTC",
                        trailingTitle: "$44,403.13",
                        trailingDescription: "↓ 12.32%",
                        trailingDescriptionColor: .semantic.error,
                        isSelected: Binding(
                            get: {
                                selection == 5
                            },
                            set: { _ in
                                selection = 5
                            }
                        )
                    ) {
                        Icon.trade
                            .color(.semantic.warning)
                            .fixedSize()
                    }
                }
                .previewLayout(.sizeThatFits)
            }
        }
    }

    @ViewBuilder static var graph: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 16))
            path.addQuadCurve(
                to: CGPoint(x: 16, y: 8),
                control: CGPoint(x: 8, y: -8)
            )
            path.addQuadCurve(
                to: CGPoint(x: 40, y: 6),
                control: CGPoint(x: 25, y: 20)
            )
            path.addQuadCurve(
                to: CGPoint(x: 64, y: 8),
                control: CGPoint(x: 50, y: 0)
            )
        }
        .stroke(Color.semantic.primary, lineWidth: 2)
        .frame(width: 64, height: 16)
    }
}
