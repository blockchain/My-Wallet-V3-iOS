import SwiftUI

/// TableRow from the Figma Component Library.
///
///
/// # Usage:
///
/// Only title is mandatory to create a Row. Rest of parameters are optional.
/// ```
/// TableRow(
///     leading: { Icon.computer.small() },
///     title: "Left Title",
///     byline: "Left Byline",
///     tag: { TagView(text: "Confirmed", variant: .success) }
/// )
/// ```
///
/// To display the trailing chevron place `tableRowChevron(true)` in your environment, e.g.
///
/// ```
///  List {
///     ForEach(...) {
///         TableRow(...)
///     }
///  }
///  .tableRowChevron(true)
/// ```
///
/// To make an actionable `TableRow` you can use `onTapGesture`, use `NavigationLink` or embed in a `Button`.
/// The best solution for you to use would depend on your use-case.
///
/// ```
///  TableRow(...)
///     .onTapGesture { ... }
///
///  NavigationLink(
///     destination: ...,
///     label: { TableRow(...) }
///  )
///
///  Button(
///     action: { ... },
///     label: { { TableRow(...) }
///   )
/// ```
/// - Version: 1.0.1
///
/// # Figma
///
///  [Table Rows](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3214%3A8702)

public struct TableRow<Title: View, Byline: View, Leading: View, Trailing: View, Footer: View>: View {

    let title: Title
    let byline: Byline
    let leading: Leading
    let trailing: Trailing
    let footer: Footer

    @Environment(\.tableRowChevron) var tableRowChevron
    @Environment(\.tableRowBackground) var tableRowBackground
    @Environment(\.tableRowHorizontalInset) var tableRowHorizontalInset
    @Environment(\.tableRowVerticalInset) var tableRowVerticalInset

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        @ViewBuilder title: () -> Title,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        @ViewBuilder trailing: () -> Trailing = EmptyView.init,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) {
        self.leading = leading()
        self.title = title()
        self.byline = byline()
        self.trailing = trailing()
        self.footer = footer()
    }

    public var body: some View {
        HStack(alignment: .tableRowContent, spacing: .zero) {
            VStack(alignment: .leading, spacing: .zero) {
                HStack(alignment: .center) {
                    leading.padding(.trailing, 8)
                    VStack(alignment: .leading, spacing: 4) {
                        title
                        byline.padding(.top, 2)
                    }
                    Spacer()
                    trailing
                }
                .alignmentGuide(.tableRowContent) { context in
                    context[VerticalAlignment.center]
                }
                footer.padding(.top, 8)
            }
            if tableRowChevron, !(trailing is Toggle<EmptyView>) {
                Icon.chevronRight
                    .color(.semantic.muted)
                    .micro()
                    .padding(.leading)
            }
        }
        .padding([.leading, .trailing], tableRowHorizontalInset)
        .padding([.top, .bottom], tableRowVerticalInset)
        .foregroundColor(.semantic.title)
        .background(tableRowBackground)
    }
}

extension TableRow {

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: some StringProtocol,
        byline: some StringProtocol,
        @ViewBuilder trailing: () -> Trailing = EmptyView.init,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Byline == TableRowByline {
        self.init(
            leading: leading,
            title: TableRowTitle(title),
            byline: TableRowByline(byline),
            trailing: trailing,
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: TableRowTitle,
        byline: TableRowByline,
        @ViewBuilder trailing: () -> Trailing = EmptyView.init,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Byline == TableRowByline {
        self.init(
            leading: leading,
            title: { title },
            byline: { byline },
            trailing: trailing,
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: some StringProtocol,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        @ViewBuilder trailing: () -> Trailing = EmptyView.init,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Byline == EmptyView {
        self.init(
            leading: leading,
            title: TableRowTitle(title),
            byline: byline,
            trailing: trailing,
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: TableRowTitle,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        @ViewBuilder trailing: () -> Trailing = EmptyView.init,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle {
        self.init(
            leading: leading,
            title: { title },
            byline: byline,
            trailing: trailing,
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: TableRowTitle,
        byline: TableRowByline,
        trailingTitle: TableRowTitle,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Byline == TableRowByline, Trailing == TableRowTitle {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: { trailingTitle },
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        @ViewBuilder title: () -> Title,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        trailingTitle: TableRowTitle,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Trailing == TableRowTitle {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: { trailingTitle },
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: TableRowTitle,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        trailingTitle: TableRowTitle,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Trailing == TableRowTitle {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: { trailingTitle },
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        @ViewBuilder title: () -> Title,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        isOn: Binding<Bool>,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Trailing == Toggle<EmptyView> {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: { Toggle(isOn: isOn, label: EmptyView.init) },
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: TableRowTitle,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        isOn: Binding<Bool>,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Trailing == Toggle<EmptyView> {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: { Toggle(isOn: isOn, label: EmptyView.init) },
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: TableRowTitle,
        byline: TableRowByline,
        isOn: Binding<Bool>,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Byline == TableRowByline, Trailing == Toggle<EmptyView> {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: { Toggle(isOn: isOn, label: EmptyView.init) },
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        @ViewBuilder title: () -> Title,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        @ViewBuilder tag: () -> TagView,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Trailing == TagView {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: tag,
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: TableRowTitle,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        @ViewBuilder tag: () -> TagView,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Trailing == TagView {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: tag,
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: TableRowTitle,
        byline: TableRowByline,
        @ViewBuilder tag: () -> TagView,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Byline == TableRowByline, Trailing == TagView {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: tag,
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        @ViewBuilder title: () -> Title,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        trailingTitle: TableRowTitle,
        trailingByline: TableRowByline,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Trailing == HStack<VStack<TupleView<(TableRowTitle, TableRowByline)>>> {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: {
                HStack(alignment: .center) {
                    VStack(alignment: .trailing, spacing: 4.pt) {
                        trailingTitle
                        trailingByline
                    }
                }
            },
            footer: footer
        )
    }

    public init(
        @ViewBuilder leading: () -> Leading = EmptyView.init,
        title: TableRowTitle,
        @ViewBuilder byline: () -> Byline = EmptyView.init,
        trailingTitle: TableRowTitle,
        trailingByline: TableRowByline,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) where Title == TableRowTitle, Trailing == HStack<VStack<TupleView<(TableRowTitle, TableRowByline)>>> {
        self.init(
            leading: leading,
            title: title,
            byline: byline,
            trailing: {
                HStack(alignment: .center) {
                    VStack(alignment: .trailing) {
                        trailingTitle
                        trailingByline
                    }
                }
            },
            footer: footer
        )
    }
}

extension VerticalAlignment {

    private struct TableRowVerticalContentAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat { context[VerticalAlignment.center] }
    }

    static let tableRowContent = VerticalAlignment(TableRowVerticalContentAlignment.self)
}

public struct TableRowTitle: TableRowLabelView {

    public var text: Text

    private var typography: Typography = .paragraph2
    private var foregroundColor: Color = .semantic.title

    public init(_ text: Text) {
        self.text = text
    }

    public var body: some View {
        text.typography(typography)
            .foregroundColor(foregroundColor)
    }

    public func typography(_ typography: Typography) -> Self {
        var it = self
        it.typography = typography
        return it
    }

    public func foregroundColor(_ foregroundColor: Color) -> Self {
        var it = self
        it.foregroundColor = foregroundColor
        return it
    }
}

public struct TableRowByline: TableRowLabelView {

    public var text: Text

    private var typography: Typography = .paragraph1
    private var foregroundColor: Color = .semantic.text
    private var multilineTextAlignment: TextAlignment = .leading

    public init(_ text: Text) {
        self.text = text
    }

    public var body: some View {
        text.typography(typography)
            .foregroundColor(foregroundColor)
            .multilineTextAlignment(multilineTextAlignment)
    }

    public func typography(_ typography: Typography) -> Self {
        var it = self
        it.typography = typography
        return it
    }

    public func foregroundColor(_ foregroundColor: Color) -> Self {
        var it = self
        it.foregroundColor = foregroundColor
        return it
    }

    public func multilineTextAlignment(_ alignment: TextAlignment) -> Self {
        var it = self
        it.multilineTextAlignment = alignment
        return it
    }
}

public protocol TableRowLabelView: View, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    init(_ text: Text)
}

extension TableRowLabelView {
    public init(_ string: some StringProtocol) { self.init(Text(string)) }
    public init(_ key: LocalizedStringKey) { self.init(Text(key)) }
    public init(@ViewBuilder label: () throws -> Text) rethrows { try self.init(label()) }
    public init(stringLiteral value: String) { self.init(Text(value)) }
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(Text(stringInterpolation.description))
    }
}

extension EnvironmentValues {

    public var tableRowChevron: Bool {
        get { self[TableRowChevronEnvironmentValue.self] }
        set { self[TableRowChevronEnvironmentValue.self] = newValue }
    }

    public var tableRowBackground: AnyView? {
        get { self[TableRowBackgroundEnvironmentValue.self] }
        set { self[TableRowBackgroundEnvironmentValue.self] = newValue }
    }

    public var tableRowHorizontalInset: CGFloat {
        get { self[TableRowHorizontalInsetEnvironmentValue.self] }
        set { self[TableRowHorizontalInsetEnvironmentValue.self] = newValue }
    }

    public var tableRowVerticalInset: CGFloat {
        get { self[TableRowVerticalInsetEnvironmentValue.self] }
        set { self[TableRowVerticalInsetEnvironmentValue.self] = newValue }
    }
}

private struct TableRowChevronEnvironmentValue: EnvironmentKey {
    static var defaultValue = false
}

private struct TableRowBackgroundEnvironmentValue: EnvironmentKey {
    static var defaultValue: AnyView?
}

private struct TableRowHorizontalInsetEnvironmentValue: EnvironmentKey {
    static let defaultValue: CGFloat = 16
}

private struct TableRowVerticalInsetEnvironmentValue: EnvironmentKey {
    static let defaultValue: CGFloat = 18
}

extension View {

    @warn_unqualified_access @ViewBuilder public func tableRowChevron(_ display: Bool) -> some View {
        environment(\.tableRowChevron, display)
    }

    @warn_unqualified_access @ViewBuilder public func tableRowBackground(_ view: (some View)?) -> some View {
        environment(\.tableRowBackground, view.map { AnyView($0) })
    }

    @warn_unqualified_access @ViewBuilder public func tableRowHorizontalInset(_ inset: CGFloat) -> some View {
        environment(\.tableRowHorizontalInset, inset)
    }

    @warn_unqualified_access @ViewBuilder public func tableRowVerticalInset(_ inset: CGFloat) -> some View {
        environment(\.tableRowVerticalInset, inset)
    }
}

struct TableRow_Previews: PreviewProvider {

    private static let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    private static let loremIpsumShort = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

    @ViewBuilder static var rows: some View {
        TableRow(
            title: "Left Title",
            byline: "Left Byline",
            footer: {
                Text(loremIpsum)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
                TagView(text: "Fastest", variant: .success)
            }
        )
        TableRow(
            title: "Left Title",
            byline: TableRowByline(Text(loremIpsum)),
            tag: { TagView(text: "New", variant: .new) },
            footer: {
                HStack {
                    Icon.alert.micro()
                    Icon.apple.micro()
                    Icon.airdrop.micro()
                }
            }
        )
        TableRow(
            title: "Left Title",
            byline: "Left Byline"
        )
        TableRow(
            title: "Left Title",
            byline: "Left Byline",
            trailingTitle: "Right Title"
        )
        TableRow(
            title: "Left Title"
        )
        TableRow(
            title: "Left Title",
            trailingTitle: "Right Title"
        )
        TableRow(
            title: {
                HStack {
                    TableRowTitle("Left Title")
                    IconButton(
                        icon: .question.circle().micro(),
                        action: {}
                    )
                }
            },
            byline: {
                TableRowByline("Left Byline")
            }
        )
        TableRow(
            title: "Left Title",
            byline: "Left Byline",
            isOn: .constant(true)
        )
        TableRow(
            title: "Left Title",
            byline: "Left Byline",
            tag: { TagView(text: "Confirmed", variant: .success) }
        )
    }

    @ViewBuilder static var rowsWithLeading: some View {
        TableRow(
            leading: { Icon.placeholder.small() },
            title: "Left Title",
            byline: "Left Byline"
        )
        TableRow(
            leading: { Icon.placeholder.small() },
            title: "Left Title",
            byline: TableRowByline(Text(loremIpsum)),
            tag: { TagView(text: "New", variant: .new) },
            footer: {
                HStack {
                    Icon.alert.micro()
                    Icon.apple.micro()
                    Icon.airdrop.micro()
                }
                .padding(.leading, Spacing.padding5)
            }
        )
        TableRow(
            leading: { Icon.placeholder.small() },
            title: "Left Title"
        )
        TableRow(
            leading: { Icon.placeholder.small() },
            title: "Left Title",
            trailingTitle: "Right Title"
        )
        TableRow(
            leading: { Icon.placeholder.small() },
            title: "Left Title",
            byline: "Left Byline",
            isOn: .constant(true)
        )
        TableRow(
            leading: { Icon.placeholder.small() },
            title: "Left Title",
            byline: "Left Byline",
            tag: { TagView(text: "Confirmed", variant: .success) }
        )
    }

    static var previews: some View {
        List { rows }
            .tableRowBackground(Color.semantic.background)
            .previewDisplayName("Default")
        List { rows }
            .tableRowBackground(Color.semantic.background)
            .tableRowChevron(true)
            .previewDisplayName("Chevron")
        List { rowsWithLeading }
            .tableRowBackground(Color.semantic.background)
            .previewDisplayName("Default with Leading Icon")
        List { rowsWithLeading }
            .tableRowBackground(Color.semantic.background)
            .tableRowChevron(true)
            .previewDisplayName("Chevron with Leading Icon")
    }

    static var testPreviews: some View {
        Group {
            Group { rows }
                .tableRowBackground(Color.semantic.background)
            Group { rows }
                .tableRowBackground(Color.semantic.background)
                .tableRowChevron(true)
            Group { rowsWithLeading }
                .tableRowBackground(Color.semantic.background)
            Group { rowsWithLeading }
                .tableRowBackground(Color.semantic.background)
                .tableRowChevron(true)
        }
    }
}
