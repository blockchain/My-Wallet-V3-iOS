// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

enum TargetSelectionPageSectionModel {
    case source(header: TargetSelectionHeaderBuilder, items: [Item])
    case card(header: TargetSelectionHeaderBuilder, items: [Item])
    case destination(header: TargetSelectionHeaderBuilder, items: [Item])
}

extension TargetSelectionPageSectionModel: AnimatableSectionModelType {
    typealias Item = TargetSelectionPageCellItem

    var items: [Item] {
        switch self {
        case .source(_, let items):
            return items
        case .card(_, items: let items):
            return items
        case .destination(_, let items):
            return items
        }
    }

    var header: TargetSelectionHeaderBuilder {
        switch self {
        case .source(let header, _):
            return header
        case .card(header: let header, _):
            return header
        case .destination(let header, _):
            return header
        }
    }

    var identity: String {
        switch self {
        case .source(let header, _),
             .destination(let header, _),
            .card(header: let header, _):
            return header.headerType.id
        }
    }

    init(original: TargetSelectionPageSectionModel, items: [Item]) {
        switch original {
        case .source(let header, _):
            self = .source(header: header, items: items)
        case .card(let header, _):
            self = .card(header: header, items: items)
        case .destination(let header, _):
            self = .destination(header: header, items: items)
        }
    }
}

extension TargetSelectionPageSectionModel: Equatable {
    static func == (lhs: TargetSelectionPageSectionModel, rhs: TargetSelectionPageSectionModel) -> Bool {
        switch (lhs, rhs) {
        case (.source(header: _, items: let left), .source(header: _, items: let right)):
            return left == right
        case (.card(header: _, items: let left), .card(header: _, items: let right)):
            return left == right
        case (.destination(header: _, items: let left), .destination(header: _, items: let right)):
            return left == right
        default:
            return false
        }
    }
}
