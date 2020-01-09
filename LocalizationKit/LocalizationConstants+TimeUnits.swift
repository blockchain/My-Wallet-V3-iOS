//
//  LocalizationConstants+TimeUnits.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 06/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension LocalizationConstants {
    struct TimeUnit {
        public struct Singular {
            public static let hour = NSLocalizedString(
                "hr",
                comment: "Dashboard: balance component - hourly price movement"
            )
            public static let day = NSLocalizedString(
                "day",
                comment: "Dashboard: balance component - daily price movement"
            )
            public static let week = NSLocalizedString(
                "week",
                comment: "Dashboard: balance component - weekly price movement"
            )
            public static let month = NSLocalizedString(
                "month",
                comment: "Dashboard: balance component - monthly price movement"
            )
            public static let year = NSLocalizedString(
                "year",
                comment: "Dashboard: balance component - years price movement"
            )
        }
        
        public struct Plural {
            public static let hours = NSLocalizedString(
                "hrs",
                comment: "Dashboard: balance component - hourly price movement"
            )
            public static let days = NSLocalizedString(
                "days",
                comment: "Dashboard: balance component - daily price movement"
            )
            public static let weeks = NSLocalizedString(
                "weeks",
                comment: "Dashboard: balance component - weekly price movement"
            )
            public static let months = NSLocalizedString(
                "months",
                comment: "Dashboard: balance component - monthly price movement"
            )
            public static let years = NSLocalizedString(
                "years",
                comment: "Dashboard: balance component - years price movement"
            )
            public static let allTime = NSLocalizedString(
                "All Time",
                comment: "Dashboard: balance component - years price movement"
            )
        }
    }
}
