// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum ImageType: Equatable, Codable, Hashable {
    case smallTag(ActivityItem.ImageSmallTag)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .type)
        switch name {
        case "SMALL_TAG":
            self = .smallTag(try ActivityItem.ImageSmallTag(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unkown type \(name)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .smallTag(let content):
            try container.encode("SMALL_TAG", forKey: .type)
            try content.encode(to: encoder)
        }
    }
}
