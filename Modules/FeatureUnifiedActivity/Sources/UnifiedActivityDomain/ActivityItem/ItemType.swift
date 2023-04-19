// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum ItemType: Equatable, Codable {

    case compositionView(ActivityItem.CompositionView)
    case leaf(LeafItemType)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .type)
        switch name {
        case "STACK_VIEW":
            self = try .compositionView(ActivityItem.CompositionView(from: decoder))
        default:
            self = try .leaf(LeafItemType(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .compositionView(let content):
            try container.encode("STACK_VIEW", forKey: .type)
            try content.encode(to: encoder)
        case .leaf(let content):
            try content.encode(to: encoder)
        }
    }
}
