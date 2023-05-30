import SwiftUI

public struct BottomBarItemView<Selection>: View where Selection: Hashable {
    public let isSelected: Bool
    public let item: BottomBarItem<Selection>

    public var body: some View {
        VStack {
            if isSelected {
                item
                    .selectedIcon
                    .color(.semantic.title)
                    .small()
            } else {
                item
                    .unselectedIcon
                    .color(.semantic.title)
                    .small()
            }
            Text(item.title)
                .foregroundColor(.semantic.title)
                .typography(.micro)
                .fixedSize()
        }
        .padding(.vertical, 8)
    }
}
