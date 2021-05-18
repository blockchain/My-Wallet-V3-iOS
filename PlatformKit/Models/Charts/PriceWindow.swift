//
//  PriceWindow.swift
//  PlatformKit
//
//  Created by AlexM on 9/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum PriceWindow: Equatable {
    public enum TimelineInterval {
        case fifteenMinutes
        case oneHour
        case twoHours
        case oneDay
        case fiveDays
    }
    
    case day(TimelineInterval?)
    case week(TimelineInterval?)
    case month(TimelineInterval?)
    case year(TimelineInterval?)
    case all(TimelineInterval?)
}

public extension PriceWindow {
    static func ==(lhs: PriceWindow, rhs: PriceWindow) -> Bool {
        switch (lhs, rhs) {
        case (.day(let left), .day(let right)):
            return left == right
        case (.week(let left), .week(let right)):
            return left == right
        case (.month(let left), .month(let right)):
            return left == right
        case (.year(let left), .year(let right)):
            return left == right
        case (.all(let left), .all(let right)):
            return left == right
        default:
            return false
        }
    }
}

extension PriceWindow {
    var timelineInterval: TimelineInterval {
        switch self {
        case .all(let interval):
            return interval ?? .fiveDays
        case .day(let interval):
            return interval ?? .fifteenMinutes
        case .week(let interval):
            return interval ?? .oneHour
        case .year(let interval):
            return interval ?? .oneDay
        case .month(let interval):
            return interval ?? .twoHours
        }
    }

    func timeIntervalSince1970(cryptoCurrency: CryptoCurrency, calendar: Calendar, date: Date) -> TimeInterval {
        var components = DateComponents()
        switch self {
        case .all:
            return cryptoCurrency.maxStartDate
        case .day:
            components.day = -1
        case .week:
            components.day = -7
        case .month:
            components.month = -1
        case .year:
            components.year = -1
        }
        return timeInterval(from: date, with: components, calendar: calendar, cryptoCurrency: cryptoCurrency)
    }

    private func timeInterval(from date: Date, with components: DateComponents, calendar: Calendar, cryptoCurrency: CryptoCurrency) -> TimeInterval {
        let dateFromComponents = calendar.date(byAdding: components, to: date)?.timeIntervalSince1970 ?? date.timeIntervalSince1970
        return max(cryptoCurrency.maxStartDate, dateFromComponents)
    }
}

public extension PriceWindow {
    var scale: Int {
        Int(timelineInterval.value)
    }
}

public extension PriceWindow.TimelineInterval {
    var value: TimeInterval {
        switch self {
        case .fifteenMinutes:
            return 900
        case .oneHour:
            return 3600
        case .twoHours:
            return 7200
        case .oneDay:
            return 86400
        case .fiveDays:
            return 432000
        }
    }
}

public extension CryptoCurrency {
    var maxStartDate: TimeInterval {
        switch self {
        case .aave:
            return 1615831200
        case .algorand:
            return 1560211225
        case .bitcoin:
            return 1282089600
        case .bitcoinCash:
            return 1500854400
        case .ethereum:
            return 1438992000
        case .pax:
            return 1555060318
        case .polkadot:
            return 1615831200
        case .stellar:
            return 1525716000
        case .tether:
            return 1511829681
        case .wDGLD:
            return 1605636000
        case .yearnFinance:
            return 1615831200
        }
    }
}
