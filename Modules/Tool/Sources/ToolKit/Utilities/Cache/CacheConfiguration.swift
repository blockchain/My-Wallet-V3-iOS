// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Foundation

/// A cache configuration.
public final class CacheConfiguration {

    public enum Flush {
        case binding(Tag.Event)
        case notification(Tag.Event)
    }

    // MARK: - Public Properties

    /// The flush notification names.
    ///
    /// When any of these notifications is received, the cache must be flushed (all values must be removed).
    public let flushNotificationNames: [Notification.Name]

    public let flushEvents: [Flush]

    // MARK: - Setup

    /// Creates a cache configuration.
    ///
    /// - Parameters:
    ///   - flushNotificationNames: An array of flush notification names.
    public init(flushNotificationNames: [Notification.Name] = [], flushEvents: [Flush] = []) {
        self.flushNotificationNames = flushNotificationNames
        self.flushEvents = flushEvents
    }
}

extension CacheConfiguration {

    /// Creates a default cache configuration with no flush notification names.
    public static func `default`() -> CacheConfiguration {
        CacheConfiguration(flushNotificationNames: [])
    }

    /// Creates a cache configuration that flushes the cache on user login and logout.
    public static func onLoginLogout() -> CacheConfiguration {
        CacheConfiguration(flushNotificationNames: [.login, .logout])
    }

    /// Creates a cache configuration that flushes the cache on user login and logout.
    public static func onLoginLogoutTransaction() -> CacheConfiguration {
        CacheConfiguration(flushNotificationNames: [.login, .logout, .transaction])
    }

    /// Creates a cache configuration that flushes the cache on user login and logout.
    public static func onLoginLogoutTransactionAndDashboardRefresh() -> CacheConfiguration {
        CacheConfiguration(flushNotificationNames: [.login, .logout, .transaction, .dashboardPullToRefresh])
    }

    public static func onLoginLogoutTransactionAndKYCStatusChanged() -> CacheConfiguration {
        CacheConfiguration(flushNotificationNames: [.login, .logout, .transaction, .kycStatusChanged])
    }

    public static func onLoginLogoutKYCChanged() -> CacheConfiguration {
        CacheConfiguration(flushNotificationNames: [.login, .logout, .kycFinished])
    }

    public static func onUserStateChanged() -> CacheConfiguration {
        CacheConfiguration(
            flushNotificationNames: [.login, .logout, .kycStatusChanged, .transaction, .dashboardPullToRefresh]
        )
    }

    public static func onLoginLogoutDebitCardRefresh() -> CacheConfiguration {
        CacheConfiguration(
            flushNotificationNames: [.debitCardRefresh, .login, .logout, .kycStatusChanged]
        )
    }

    public static func on(_ events: Tag.Event...) -> CacheConfiguration {
        CacheConfiguration(
            flushEvents: events.map(Flush.notification)
        )
    }

    public static func binding(_ events: Tag.Event...) -> CacheConfiguration {
        CacheConfiguration(
            flushEvents: events.map(Flush.binding)
        )
    }

    public func combined(with configuration: CacheConfiguration) -> CacheConfiguration {
        .init(flushNotificationNames: flushNotificationNames + configuration.flushNotificationNames, flushEvents: flushEvents + configuration.flushEvents)
    }

    public static func + (lhs: CacheConfiguration, rhs: CacheConfiguration) -> CacheConfiguration {
        lhs.combined(with: rhs)
    }
}
