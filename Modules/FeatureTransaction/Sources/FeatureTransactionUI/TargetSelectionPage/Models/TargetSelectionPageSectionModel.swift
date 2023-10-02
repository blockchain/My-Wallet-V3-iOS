// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

struct TargetSelectionPageSectionModel: Equatable, AnimatableSectionModelType {

    enum Section: Hashable {
        case source
        case inputField
        case memoField
        case card
        case accounts
    }

    let header: TargetSelectionHeader
    let items: [TargetSelectionPageCellItem]
    let identity: Section

    init(
        identity: Section,
        header: TargetSelectionHeader,
        items: [TargetSelectionPageCellItem]
    ) {
        self.identity = identity
        self.header = header
        self.items = items
    }

    init(original: TargetSelectionPageSectionModel, items: [TargetSelectionPageCellItem]) {
        self.init(identity: original.identity, header: original.header, items: items)
    }
}
