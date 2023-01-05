// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum ImageType: Equatable, Codable, Hashable {

    private enum Constants {
        static let smallTag = "SMALL_TAG"
        static let singleIcon = "SINGLE_ICON"
    }

    case smallTag(ActivityItem.ImageSmallTag)
    case singleIcon(ActivityItem.ImageSingleIcon)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .type)
        switch name {
        case Constants.smallTag:
            self = .smallTag(try ActivityItem.ImageSmallTag(from: decoder))
        case Constants.singleIcon:
            self = .singleIcon(try ActivityItem.ImageSingleIcon(from: decoder))
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
            try container.encode(Constants.smallTag, forKey: .type)
            try content.encode(to: encoder)
        case .singleIcon(let content):
            try container.encode(Constants.singleIcon, forKey: .type)
            try content.encode(to: encoder)
        }
    }
}
