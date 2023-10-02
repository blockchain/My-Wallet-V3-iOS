// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary

public struct SelectionItemViewModel {

    public enum Thumb {
        case image(ImageLocation)
        case emoji(String)
        case none
    }

    public var accessibilityId: String { id }
    public let id: String

    public let title: String
    public var subtitle: String
    public let thumb: Thumb

    public init(id: String, title: String, subtitle: String, thumb: Thumb) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.thumb = thumb
    }
}

extension SelectionItemViewModel: Equatable {
    public static func == (lhs: SelectionItemViewModel, rhs: SelectionItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension SelectionItemViewModel: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.title < rhs.title
    }
}

extension SelectionItemViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
