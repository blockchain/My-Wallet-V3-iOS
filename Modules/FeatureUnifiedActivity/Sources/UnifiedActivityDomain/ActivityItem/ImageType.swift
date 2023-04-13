// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum ImageType: Equatable, Codable, Hashable {

    private enum Constants {
        static let smallTag = "SMALL_TAG"
        static let singleIcon = "SINGLE_ICON"
        static let overlappingPair = "OVERLAPPING_PAIR"
    }

    case smallTag(ActivityItem.ImageSmallTag)
    case singleIcon(ActivityItem.ImageSingleIcon)
    case overlappingPair(ActivityItem.ImageOverlappingPair)

    enum CodingKeys: CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .type)
        switch name {
        case Constants.smallTag:
            self = try .smallTag(ActivityItem.ImageSmallTag(from: decoder))
        case Constants.singleIcon:
            self = try .singleIcon(ActivityItem.ImageSingleIcon(from: decoder))
        case Constants.overlappingPair:
            self = try .overlappingPair(ActivityItem.ImageOverlappingPair(from: decoder))
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
        case .smallTag(let content):
            try container.encode(Constants.smallTag, forKey: .type)
            try content.encode(to: encoder)
        case .singleIcon(let content):
            try container.encode(Constants.singleIcon, forKey: .type)
            try content.encode(to: encoder)
        case .overlappingPair(let content):
            try container.encode(Constants.overlappingPair, forKey: .type)
            try content.encode(to: encoder)
        }
    }
}
