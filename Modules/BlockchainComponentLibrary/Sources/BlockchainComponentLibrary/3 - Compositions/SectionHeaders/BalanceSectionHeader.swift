// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// BalanceSectionHeader from the Figma Component Library.
///
/// # Figma
///
///  [Section Header](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11327)
public struct BalanceSectionHeader<Trailing: View>: View {

    private let header: String?
    private let title: String?
    private let subtitle: String?
    @ViewBuilder private let trailing: () -> Trailing

    /// Initialize a Balance Section Header
    /// - Parameters:
    ///   - header: (Optional) Title of the section header
    ///   - title: Title of the header
    ///   - subtitle: Subtitle of the header
    ///   - trailing: Generic view displayed trailing in the header.
    public init(
        header: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.header = header
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                if let header {
                    Text(header)
                        .typography(.caption2.slashedZero())
                        .foregroundColor(.semantic.title)
                }
                if let title {
                    Text(title)
                        .typography(.title3.slashedZero())
                        .foregroundColor(.semantic.title)
                }
                if let subtitle {
                    Text(subtitle)
                        .typography(.paragraph2.slashedZero())
                        .foregroundColor(.semantic.body)
                }
            }
            Spacer()
            trailing()
                .frame(maxHeight: 28)
        }
        .padding([.leading, .trailing], Spacing.padding2)
        .background(Color.semantic.background)
        .listRowInsets(EdgeInsets())
    }
}

struct BalanceSectionHeader_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            BalanceSectionHeader(
                title: "$12,293.21",
                subtitle: "0.1393819 BTC"
            )
            .redacted(reason: .placeholder)

            BalanceSectionHeader(
                subtitle: "0.1393819 BTC"
            )

            BalanceSectionHeader(
                header: "Your total BTC",
                title: "$12,293.21",
                subtitle: "0.1393819 BTC",
                trailing: { IconButton(icon: .favorite) {} }
            )

            BalanceSectionHeader(
                title: "$12,293.21",
                subtitle: "0.1393819 BTC",
                trailing: { IconButton(icon: .favorite) {} }
            )

            BalanceSectionHeader(
                header: "Your total BTC",
                title: "$12,293.21",
                subtitle: "0.1393819 BTC",
                trailing: { IconButton(icon: .favorite) {} }
            )
            .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .frame(width: 375)
    }
}
