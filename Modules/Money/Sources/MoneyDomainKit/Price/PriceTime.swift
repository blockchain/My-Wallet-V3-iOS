// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum PriceTime: Hashable {
    case now
    case oneDay
    case time(Date)

    public var date: Date {
        switch self {
        case .now:
            return Date()
        case .oneDay:
            return Date().addingTimeInterval(-24 * 60 * 60)
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
