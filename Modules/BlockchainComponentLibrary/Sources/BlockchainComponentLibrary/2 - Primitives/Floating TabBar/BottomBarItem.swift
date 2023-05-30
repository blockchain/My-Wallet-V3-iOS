import SwiftUI

public struct BottomBarItem<Selection>: Identifiable where Selection: Hashable {
    public var id: Selection
    public let selectedIcon: Icon
    public let unselectedIcon: Icon
    public let title: String

    public init(
        id: Selection,
        selectedIcon: Icon,
        unselectedIcon: Icon,
        title: String
    ) {
        self.id = id
        self.selectedIcon = selectedIcon
        self.unselectedIcon = unselectedIcon
        self.title = title
    }
}

extension BottomBarItem: Equatable, Hashable {}
