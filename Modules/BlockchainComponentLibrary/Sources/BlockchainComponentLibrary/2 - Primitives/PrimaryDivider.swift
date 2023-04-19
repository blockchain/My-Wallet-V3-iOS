// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import SwiftUI

/// A visual element used to separate other content.
///
/// When contained in a stack, the divider extends across the minor axis of the stack, or horizontally when not in a stack.
/// Identical behaviour to SwiftUI's native `Divider`.
///
/// # Figma
///
/// [PrimaryDivider](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=364%3A9676)
public struct PrimaryDivider: View {
    public init() {}

    public var body: some View {
        Divider()
            .background(
                Color(
                    light: .semantic.light,
                    dark: .palette.dark700
                )
            )
    }
}

struct PrimaryDivider_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PrimaryDivider()
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Horizontal")

        HStack {
            PrimaryDivider()
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Vertical")
    }
}

public struct DSAPrimaryDivider: View {
    let color: Color = .semantic.light
    let width: CGFloat = 1

    public init() {}

    public var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: width)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct SAPrimaryDivider_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DSAPrimaryDivider()
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Horizontal")

        HStack {
            DSAPrimaryDivider()
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Vertical")
    }
}

public struct DividedVStack<Content: View, Divider: View>: View {

    public var content: Content
    public var divider: () -> Divider

    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?

    public init(
        @ViewBuilder divider: @escaping () -> Divider = PrimaryDivider.init,
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.divider = divider
        self.alignment = alignment
        self.spacing = spacing
    }

    public var body: some View {
        _VariadicView.Tree(DividedVStackLayout(alignment: alignment, spacing: spacing, divider: divider)) {
            content
        }
    }
}

public struct DividedVStackLayout<Divider: View>: _VariadicView_UnaryViewRoot {

    public let divider: () -> Divider

    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        divider: @escaping () -> Divider
    ) {
        self.divider = divider
        self.alignment = alignment
        self.spacing = spacing
    }

    @ViewBuilder
    public func body(children: _VariadicView.Children) -> some View {
        let last = children.last?.id
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(children) { child in
                child
                if child.id != last {
                    divider()
                }
            }
        }
    }
}
