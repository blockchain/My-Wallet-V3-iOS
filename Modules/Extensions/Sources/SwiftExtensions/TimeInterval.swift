// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension TimeInterval {

    /// Represents miliseconds in seconds using the Gregorian calendar
    public static func miliseconds(_ miliseconds: TimeInterval) -> TimeInterval {
        miliseconds / TimeInterval(1000)
    }

    /// Syntactic sugar for legibility
    public static func seconds(_ seconds: TimeInterval) -> TimeInterval {
        seconds
    }

    /// Represents minutes in seconds using the Gregorian calendar
    public static func minutes(_ minutes: Int) -> TimeInterval {
        TimeInterval(minutes) * duration(of: .minute)
    }

    /// Represents hours in s..dateIntervaeconds using the Gregorian calendar
    public static func hours(_ hours: Int) -> TimeInterval {
        TimeInterval(hours) * .duration(of: .hour)
    }

    /// Represents days in seconds using the Gregorian calendar
    public static func days(_ days: Int) -> TimeInterval {
        TimeInterval(days) * .duration(of: .day)
    }

    /// Represents weeks in seconds using the Gregorian calendar
    public static func weeks(_ weeks: Int) -> TimeInterval {
        TimeInterval(weeks) * .duration(of: .weekOfMonth)
    }

    /// Represents a number of typical months in seconds using the Gregorian calendar
    public static func months(_ months: Int) -> TimeInterval {
        TimeInterval(months) * .duration(of: .month)
    }

    /// Represents a number of typical years in seconds using the Gregorian calendar
    public static func years(_ years: Int) -> TimeInterval {
        TimeInterval(years) * .duration(of: .year)
    }

    /// Represents an hour from now in seconds using the Gregorian calendar
    public static let hour: TimeInterval = .hours(1)

    /// Represents a day from now in seconds using the Gregorian calendar
    public static let day: TimeInterval = .days(1)

    /// Represents a week from now in seconds using the Gregorian calendar
    public static let week: TimeInterval = .weeks(1)

    /// Represents a month from now in seconds using the Gregorian calendar
    public static let month: TimeInterval = .months(1)

    /// Represents a year from now in seconds using the Gregorian calendar
    public static let year: TimeInterval = .years(1)

    private static func duration(
        of component: Calendar.Component,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> TimeInterval {
        guard let dateInterval = calendar.dateInterval(of: component, for: Date()) else {
            preconditionFailure("calendar.dateInterval failed with \(calendar.identifier) and \(component)")
        }
        return dateInterval.duration
    }

}
