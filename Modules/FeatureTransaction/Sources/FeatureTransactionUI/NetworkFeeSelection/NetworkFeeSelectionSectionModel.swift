// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxDataSources

enum NetworkFeeSelectionSectionItem: Equatable, IdentifiableType {
    case label(LabelContent)
    case radio(RadioLineItemCellPresenter)
    case button(ButtonViewModel)
    case separator(Int)

    var identity: AnyHashable {
        switch self {
        case .label(let content):
            content.text
        case .radio(let presenter):
            presenter.identity
        case .button(let viewModel):
            viewModel.textRelay.value + viewModel.isEnabledRelay.value.description
        case .separator(let index):
            "\(index)"
        }
    }

    static func == (lhs: NetworkFeeSelectionSectionItem, rhs: NetworkFeeSelectionSectionItem) -> Bool {
        switch (lhs, rhs) {
        case (.radio(let left), .radio(let right)):
            left == right
        case (.button(let left), .button(let right)):
            left.isEnabledRelay.value == right.isEnabledRelay.value
        case (.separator(let left), .separator(let right)):
            left == right
        case (.label(let left), .label(let right)):
            left == right
        default:
            false
        }
    }
}

struct NetworkFeeSelectionSectionModel: SectionModelType {
    typealias Item = NetworkFeeSelectionSectionItem

    var items: [NetworkFeeSelectionSectionItem]

    init(items: [NetworkFeeSelectionSectionItem]) {
        self.items = items
    }

    init(original: NetworkFeeSelectionSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

extension NetworkFeeSelectionSectionModel: Equatable {
    static func == (lhs: NetworkFeeSelectionSectionModel, rhs: NetworkFeeSelectionSectionModel) -> Bool {
        lhs.items == rhs.items
    }
}
