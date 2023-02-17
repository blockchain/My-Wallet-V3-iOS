// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import SwiftUI

/// LargeSegmentedControl from the Figma Component Library.
///
///
/// # Usage:
///
/// The LargeSegmentedControl can be initialized with any number of items,
/// and a selection parameter, which indicates the initial selection state.
///
/// `LargeSegmentedControl(
///     items: [
///         LargeSegmentedControl.Item(title: "Leading", identifier: "leading"),
///         LargeSegmentedControl.Item(title: "Trailing", identifier: "trailing")
///     ],
///     selection: $selected
/// )`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Controls](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=6%3A544)
public struct LargeSegmentedControl<Selection: Hashable>: View {

    private var items: [Item]

    @Binding private var selection: Selection
    @Environment(\.layoutDirection) private var layoutDirection

    /// Create a LargeSegmentedControl view with any number of items and a selection state.
    /// - Parameter items: Items who represents the buttons inside the segmented control
    /// - Parameter selection: Binding for `selection` from `items` for the currently selected item.
    public init(
        items: [Item],
        selection: Binding<Selection>
    ) {
        self.items = items
        _selection = selection
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button(
                    title: item.title,
                    icon: item.icon,
                    isOn: Binding(
                        get: {
                            selection == item.identifier
                        },
                        set: { _ in
                            withAnimation(.easeInOut) {
                                selection = item.identifier
                            }
                        }
                    )
                )
                .anchorPreference(key: ButtonPreferenceKey.self, value: .bounds, transform: { anchor in
                    [item.identifier: anchor]
                })
            }
        }
        .padding(2)
        .backgroundPreferenceValue(ButtonPreferenceKey.self) { value in
            GeometryReader { proxy in
                if let anchor = value[selection] {
                    movingRectangle(proxy: proxy, anchor: anchor)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                .fill(Color.semantic.medium)
        )
    }

    @ViewBuilder private func movingRectangle(proxy: GeometryProxy, anchor: Anchor<CGRect>) -> some View {
        RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
            .fill(Color.semantic.background)
            .shadow(
                color: Color(
                    light: .palette.black.opacity(0.06),
                    dark: .palette.black.opacity(0.12)
                ),
                radius: 1,
                x: 0,
                y: 3
            )
            .shadow(
                color: Color(
                    light: .palette.black.opacity(0.15),
                    dark: .palette.black.opacity(0.12)
                ),
                radius: 8,
                x: 0,
                y: 3
            )
            .frame(
                width: proxy[anchor].width,
                height: proxy[anchor].height
            )
            .offset(
                x: xOffset(for: proxy[anchor], in: proxy),
                y: proxy[anchor].minY
            )
            .animation(.interactiveSpring())
    }

    private func xOffset(for rect: CGRect, in proxy: GeometryProxy) -> CGFloat {
        switch layoutDirection {
        case .rightToLeft:
            return proxy.size.width - rect.minX - rect.width
        default:
            return rect.minX
        }
    }
}

extension LargeSegmentedControl {

    public struct Item: Identifiable {

        let title: String
        let icon: Icon?
        let identifier: Selection

        public var id: Selection { identifier }

        /// Create an Item which is the element to pass into the LargeSegmentedControl,
        /// as a representation for the buttons to be shown on the control.
        /// The parameters defined on the items are the data used to display a button.
        /// - Parameter title: title of the item, will be the title of the button
        /// - Parameter identifier: unique identifier which is used to determine which button is on the selected state. The identifier must to be set in order for the control to work with unique elements.
        public init(
            title: String,
            icon: Icon? = nil,
            identifier: Selection
        ) {
            self.title = title
            self.icon = icon
            self.identifier = identifier
        }
    }
}

private struct ButtonPreferenceKey: PreferenceKey {
    static var defaultValue: [AnyHashable: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [AnyHashable: Anchor<CGRect>],
        nextValue: () -> [AnyHashable: Anchor<CGRect>]
    ) {
        value.merge(
            nextValue(),
            uniquingKeysWith: { _, next in
                next
            }
        )
    }
}

struct LargeSegmentedControl_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PreviewController(
                items: [
                    LargeSegmentedControl.Item(title: "Leading", identifier: "leading"),
                    LargeSegmentedControl.Item(title: "Trailing", identifier: "trailing")
                ],
                selection: "leading"
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("LargeSegmentedControl")

            PreviewController(
                items: [
                    LargeSegmentedControl.Item(title: "Leading", identifier: "leading"),
                    LargeSegmentedControl.Item(title: "Trailing", identifier: "trailing")
                ],
                selection: "trailing"
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Initial Selection")

            PreviewController(
                items: [
                    LargeSegmentedControl.Item(title: "First", identifier: "first"),
                    LargeSegmentedControl.Item(title: "Second", identifier: "second"),
                    LargeSegmentedControl.Item(title: "Third", identifier: "third"),
                    LargeSegmentedControl.Item(title: "Fourth", identifier: "fourth")
                ],
                selection: "first"
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Multi items")
        }
        .padding()
    }

    struct PreviewController<Selection: Hashable>: View {
        let items: [LargeSegmentedControl<Selection>.Item]
        @State var selection: Selection

        init(
            items: [LargeSegmentedControl<Selection>.Item],
            selection: Selection
        ) {
            self.items = items
            _selection = State(initialValue: selection)
        }

        var body: some View {
            LargeSegmentedControl(
                items: items,
                selection: $selection
            )
        }
    }
}
