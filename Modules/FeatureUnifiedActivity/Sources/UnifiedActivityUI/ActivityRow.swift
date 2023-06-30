// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Foundation
import SwiftUI
import UnifiedActivityDomain

public struct ActivityRow: View {

    @BlockchainApp var app
    @Environment(\.context) var context
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.colorScheme) private var colorScheme

    var isDarkMode: Bool {
        colorScheme == .dark
    }

    let itemType: ItemType

    @State private var isHidingBalance: Bool = false
    @Binding private var isSelected: Bool

    private let isSelectable: Bool
    let action: () -> Void

    /// Create a Activity Row with the given data.
    ///
    ///
    /// - Parameters:
    ///   - activityEntry: The activity entry used to configure the view
    ///   - isSelected: Binding for the selection state
    ///   - leading: View on the leading side of the row.
    ///
    public init(
        itemType: ItemType,
        isSelected: Binding<Bool>? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.itemType = itemType
        self.isSelectable = isSelected != nil
        _isSelected = isSelected ?? .constant(false)
        self.action = action
    }

    public init(
        activityEntry: ActivityEntry,
        isSelected: Binding<Bool>? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.itemType = ItemType.compositionView(activityEntry.item)
        self.isSelectable = isSelected != nil
        _isSelected = isSelected ?? .constant(false)
        self.action = action
    }

    public var body: some View {
        Button {
            isSelected = true
            action()
        } label: {
            switch itemType {
            case .compositionView(let view):
                compositionView(with: view)
            case .leaf(let type):
                LeafItemTypeView(item: type)
                    .context([blockchain.ux.activity.row.button.id: type.id])
            }
        }
        .buttonStyle(SimpleBalanceRowStyle(isSelectable: isSelectable))
        .bindings {
            subscribe($isHidingBalance, to: blockchain.ux.dashboard.is.hiding.balance)
        }
    }

    var isRedacted: Bool {
        if let isHidingBalance = context[blockchain.ux.dashboard.is.hiding.balance] as? Bool {
            return isHidingBalance
        }
        if #available(iOS 15.0, *) {
            return isHidingBalance || redactionReasons.contains(.privacy)
        } else {
            return isHidingBalance
        }
    }

    @ViewBuilder
    @MainActor
    func compositionView(with item: ActivityItem.CompositionView) -> some View {
        HStack(alignment: .center, spacing: 16) {
            imageView(with: isDarkMode ? item.leadingImageDark : item.leadingImage)

            VStack(alignment: .leading, spacing: 3) {
                ForEach(item.leading) {
                    LeafItemTypeView(item: $0)
                        .context([blockchain.ux.activity.row.button.id: $0.id])
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                ForEach(item.trailing) {
                    LeafItemTypeView(item: $0, isRedacted: isRedacted)
                        .context([blockchain.ux.activity.row.button.id: $0.id])
                }
            }
            imageView(with: item.trailingImage)
        }
    }

    @ViewBuilder
    @MainActor
    private func imageView(with image: ImageType?) -> some View {
        if #available(iOS 15.0, *) {
            ActivityRowImage(image: image)
        } else {
            // Fallback on earlier versions
        }
    }

    struct LeafItemTypeView: View {

        @BlockchainApp var app

        var item: LeafItemType
        var isRedacted: Bool = false

        let tag = blockchain.ux.activity.row.button

        var body: some View {
            switch item {
            case .text(let textElement):
                Text(isRedacted ? "••••" : textElement.value)
                    .lineLimit(1)
                    .typography(textElement.style.typography.typography())
                    .foregroundColor(textElement.style.color.uiColor())
            case .button(let buttonElement):
                Button {
                    $app.post(event: tag.tap)
                } label: {
                    Text(buttonElement.text)
                        .typography(.body2)
                }
                .batch {
                    set(tag.tap, to: buttonElement.action)
                }

            case .badge(let badgeElement):
                TagView(
                    text: badgeElement.value,
                    variant: badgeElement.style.variant()
                )
            }
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

extension LeafItemType: Identifiable {
    public var id: String {
        switch self {
        case .badge(let item):
            return item.id
        case .text(let item):
            return item.id
        case .button(let item):
            return item.id
        }
    }
}
