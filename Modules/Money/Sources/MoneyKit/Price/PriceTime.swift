// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

private let yesterday = Date().addingTimeInterval(-24 * 60 * 60)

public enum PriceTime {
    case now
    case oneDay
    case time(Date)

    var isNow: Bool {
        switch self {
        case .now: return true
        default: return false
        }
    }

    public var date: Date {
        switch self {
        case .now:
            return Date()
        case .oneDay:
            return yesterday
        case .time(let date):
            return date
        }
    }

    public var timestamp: String? {
        switch self {
        case .now:
            return nil
        case .oneDay, .time:
            return date.timeIntervalSince1970.string(with: 0)
        }
    }

    public var isSpecificDate: Bool {
        switch self {
        case .now, .oneDay:
            return false
        case .time:
            return true
        }
    }
}

extension PriceTime: Equatable {}
extension PriceTime: Hashable {}

extension PriceTime: Identifiable {

    public var id: String {
        switch self {
        case .now:
            return "now"
        case .oneDay:
            return "yesterday"
        case .time(let date):
            return date.timeIntervalSince1970.description
        }
    }
}

extension PriceTime: LosslessStringConvertible {

    public init?(_ description: String) {
        switch description {
        case "now":
            self = .now
        case "yesterday":
            self = .oneDay
        default:
            guard let t = TimeInterval(description) else { return nil }
            self = .time(Date(timeIntervalSince1970: t))
        }
    }

    public var description: String { id }
}

extension PriceTime: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let time = try Self(container.decode(String.self)) else {
            throw DecodingError.valueNotFound(String.self, .init(codingPath: decoder.codingPath, debugDescription: "Expected 'now', 'yesterday' or epoch time"))
        }
        self = time
    }
}

extension PriceTime: RawRepresentable {

    public var rawValue: String { id }
    public init?(rawValue: String) {
        self.init(rawValue)
    }
}
