import SwiftUI

public struct BottomBar<Selection>: View where Selection: Hashable {
    @Binding public var selectedItem: Selection
    public let items: [BottomBarItem<Selection>]

    public init(selectedItem: Binding<Selection>, items: [BottomBarItem<Selection>]) {
        _selectedItem = selectedItem
        self.items = items
    }

    public var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 32) {
                ForEach(items, id: \.self) { item in
                    Button {
                        withAnimation { selectedItem = item.id }
                    } label: {
                        BottomBarItemView(
                            isSelected: selectedItem == item.id,
                            item: item
                        )
                    }
                }
            }
            .padding([.horizontal], Spacing.padding4)
            .padding(.vertical, 0)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.semantic.background)
            )
        }
    }
}
