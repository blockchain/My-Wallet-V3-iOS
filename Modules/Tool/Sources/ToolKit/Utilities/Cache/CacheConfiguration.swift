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

    /// Creates a cache configuration that flushes the cache on user logout.
    public static func onLogout() -> CacheConfiguration {
        .on(blockchain.session.event.did.sign.out)
    }

    /// Creates a cache configuration that flushes the cache on user login and logout.
    public static func onLoginLogout() -> CacheConfiguration {
        .on(
            blockchain.session.event.did.sign.in,
            blockchain.session.event.did.sign.out
        )
    }

    public static func onLoginLogoutTransaction() -> CacheConfiguration {
        .on(
            blockchain.session.event.did.sign.in,
            blockchain.ux.transaction.event.did.finish,
            blockchain.session.event.did.sign.out
        )
    }

    public static func onLoginLogoutTransactionAndDashboardRefresh() -> CacheConfiguration {
        .on(
            blockchain.session.event.did.sign.in,
            blockchain.ux.transaction.event.did.finish,
            blockchain.ux.home.event.did.pull.to.refresh,
            blockchain.session.event.did.sign.out
        )
    }

    public static func onLoginLogoutTransactionAndKYCStatusChanged() -> CacheConfiguration {
        .on(
            blockchain.session.event.did.sign.in,
            blockchain.ux.transaction.event.did.finish,
            blockchain.ux.kyc.event.status.did.change,
            blockchain.session.event.did.sign.out
        )
    }

    public static func onLoginLogoutKYCChanged() -> CacheConfiguration {
        .on(
            blockchain.session.event.did.sign.in,
            blockchain.ux.kyc.event.status.did.change,
            blockchain.session.event.did.sign.out
        )
    }

    public static func onUserStateChanged() -> CacheConfiguration {
        .on(
            blockchain.session.event.did.sign.in,
            blockchain.ux.transaction.event.did.finish,
            blockchain.ux.kyc.event.status.did.change,
            blockchain.ux.home.event.did.pull.to.refresh,
            blockchain.session.event.did.sign.out
        )
    }

    public static func onLoginLogoutDebitCardRefresh() -> CacheConfiguration {
        CacheConfiguration(
            flushNotificationNames: [.debitCardRefresh]
        )
        .combined(
            with: .on(
                blockchain.session.event.did.sign.in,
                blockchain.ux.kyc.event.status.did.change,
                blockchain.session.event.did.sign.out
            )
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
