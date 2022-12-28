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

public struct ForEachWithDivider<
    Data: RandomAccessCollection,
    Content: View,
    ID: Hashable
>: View {

    var data: Data
    var id: KeyPath<Data.Element, ID>
    var content: (Data.Element) -> Content

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.content = content
    }

    public var body: some View {
        ForEach(data.indexed(), id: (\IndexedCollection<Data>.Element.element).appending(path: id)) { index, element in
            content(element)
            if index != data.indices.last {
                PrimaryDivider()
            }
        }
    }
}
