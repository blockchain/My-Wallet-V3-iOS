// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A price window, representing a time range, coupled with a timeline interval.
public enum PriceWindow: Hashable {

    case day(TimelineInterval = .fifteenMinutes)

    case week(TimelineInterval = .oneHour)

    case month(TimelineInterval = .twoHours)

    case year(TimelineInterval = .oneDay)

    case all(TimelineInterval = .fiveDays)

    // MARK: - Public Types

    /// A timeline interval, representing the number of seconds between consecutive items in a timeline.
    public enum TimelineInterval: TimeInterval {

        case fifteenMinutes = 900

        case oneHour = 3600

        case twoHours = 7200

        case oneDay = 86400

        case fiveDays = 432000
    }

    // MARK: - Internal Properties

    /// The scale of the price window, representing the number of seconds between consecutive items in a timeline.
    public var scale: Int {
        Int(timelineInterval.rawValue)
    }

    /// The timeline interval associated with the price window.
    var timelineInterval: TimelineInterval {
        switch self {
        case .day(let interval),
             .week(let interval),
             .month(let interval),
             .year(let interval),
             .all(let interval):
            return interval
        }
    }

    // MARK: - Private Properties

    /// The earliest start date for a price window.
    private var maxStartDate: TimeInterval {
        1438992000 // 8 August 2015 00:00:00 GMT
    }

    // MARK: - Public Methods

    /// Gets the unix time of the start of the price window, relative to the given date, using the given calendar.
    ///
    /// - Parameters:
    ///   - calendar: A calendar.
    ///   - date:     A date, representing the end of the price window.
    public func timeIntervalSince1970(calendar: Calendar, date: Date) -> TimeInterval {
        var components = DateComponents()
        switch self {
        case .day:
            components.day = -1
        case .week:
            components.day = -7
        case .month:
            components.month = -1
        case .year:
            components.year = -1
        case .all:
            return maxStartDate
        }
        return calendar.date(byAdding: components, to: date)?.timeIntervalSince1970 ?? maxStartDate
    }
}
