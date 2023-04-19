// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace

extension BottomBarItem {
    static func create(from tab: Tab) -> BottomBarItem<Tag.Reference> {
        BottomBarItem<Tag.Reference>(
            id: tab.tag,
            selectedIcon: tab.icon.renderingMode(.original),
            unselectedIcon: tab.unselectedIcon?.renderingMode(.original) ?? tab.icon.renderingMode(.original),
            title: tab.name.localized()
        )
    }
}
