// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum DetailType: Equatable, Codable {

    case groupedItems(ActivityDetail.GroupedItems)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .type)
        switch name {
        case "GROUPED_ITEMS":
            self = .groupedItems(try ActivityDetail.GroupedItems(from: decoder))
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
        case .groupedItems(let content):
            try container.encode("GROUPED_ITEMS", forKey: .type)
            try content.encode(to: encoder)
        }
    }
}
