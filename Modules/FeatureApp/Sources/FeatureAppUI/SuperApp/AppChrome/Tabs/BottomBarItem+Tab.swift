// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace

extension BottomBarItem {
    static func create(from tab: Tab) -> BottomBarItem<Tag.Reference> {
        BottomBarItem<Tag.Reference>(
            id: tab.tag,
            selectedIcon: tab.icon,
            unselectedIcon: tab.unselectedIcon ?? tab.icon,
            title: tab.name.localized()
        )
    }
}
