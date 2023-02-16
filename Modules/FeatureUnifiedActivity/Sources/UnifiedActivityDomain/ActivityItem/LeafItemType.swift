// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum LeafItemType: Equatable, Codable, Hashable {
    case text(ActivityItem.Text)
    case button(ActivityItem.Button)
    case badge(ActivityItem.Badge)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .type)
        switch name {
        case "TEXT":
            self = .text(try ActivityItem.Text(from: decoder))
        case "BUTTON":
            self = .button(try ActivityItem.Button(from: decoder))
        case "BADGE":
            self = .badge(try ActivityItem.Badge(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknow type \(name)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let content):
            try container.encode("TEXT", forKey: .type)
            try content.encode(to: encoder)
        case .button(let content):
            try container.encode("BUTTON", forKey: .type)
            try content.encode(to: encoder)
        case .badge(let content):
            try container.encode("BADGE", forKey: .type)
            try content.encode(to: encoder)
        }
    }
}
