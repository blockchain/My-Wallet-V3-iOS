// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation

extension ActivityItem {
    public struct Badge: Equatable, Codable, Hashable, Identifiable {
        public var id: String = {
            UUID().uuidString
        }()
        public let value: String
        public let style: BadgeStyle
    }
}

public enum BadgeStyle: String, Codable, Hashable {
    case `default`
    case infoAlt
    case success
    case warning
    case error
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = BadgeStyle(rawValue: string) ?? .unknown
    }

    public func variant() -> TagView.Variant {
        switch self {
        case .default:
            return TagView.Variant.default
        case .infoAlt:
            return TagView.Variant.infoAlt
        case .success:
            return TagView.Variant.success
        case .warning:
            return TagView.Variant.warning
        case .error:
            return TagView.Variant.error
        case .unknown:
            return TagView.Variant.default
        }
    }
}
