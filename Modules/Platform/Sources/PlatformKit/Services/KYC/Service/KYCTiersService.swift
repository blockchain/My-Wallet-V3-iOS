// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import Errors
import RxSwift
import ToolKit

public protocol KYCVerificationServiceAPI: AnyObject {

    /// Returnes whether or not the user is Tier 2 approved.
    var isKYCVerified: AnyPublisher<Bool, Never> { get }

    // Returns whether or not the user can make purchases
    var canPurchaseCrypto: AnyPublisher<Bool, Never> { get }
}

public protocol KYCTiersServiceAPI: KYCVerificationServiceAPI {

    /// Returns the current cached value for the KYC Tiers. Fetches them if they are not already cached.
    var tiers: AnyPublisher<KYC.UserTiers, Nabu.Error> { get }

    /// Returns a stream of KYC Tiers.
    ///
    /// Tiers are taken from cache or fetched if the cache is empty. When the cache is invalidated, tiers are re-fetched from source.
    var tiersStream: AnyPublisher<KYC.UserTiers, Nabu.Error> { get }

    /// Fetches the tiers from remote
    func fetchTiers() -> AnyPublisher<KYC.UserTiers, Nabu.Error>

    /// Fetches the KYC overview (features and limits) for the logged-in user
    func fetchOverview() -> AnyPublisher<KYCLimitsOverview, Nabu.Error>
}

extension KYCTiersServiceAPI {

    /// Returnes whether or not the user is Tier 2 approved.
    public var isKYCVerified: AnyPublisher<Bool, Never> {
        fetchTiers()
            .map(\.isVerifiedApproved)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    /// Returns whether or not the user can make purchases
    public var canPurchaseCrypto: AnyPublisher<Bool, Never> {
        fetchTiers()
            .map { userTiers -> Bool in
                // users can make purchases if they are at least Tier 2 approved
                userTiers.canPurchaseCrypto()
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}

final class KYCTiersService: KYCTiersServiceAPI {

    // MARK: - Types

    private struct Key: Hashable {}

    // MARK: - Exposed Properties

    var tiers: AnyPublisher<KYC.UserTiers, Nabu.Error> {
        cachedTiers.get(key: Key())
    }

    var tiersStream: AnyPublisher<KYC.UserTiers, Nabu.Error> {
        cachedTiers
            .stream(key: Key())
            .setFailureType(to: Nabu.Error.self)
            .compactMap { result -> KYC.UserTiers? in
                guard case .success(let tiers) = result else {
                    return nil
                }
                return tiers
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let app: AppProtocol
    private let client: KYCClientAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    private let cachedTiers: CachedValueNew<
        Key,
        KYC.UserTiers,
        Nabu.Error
    >

    private let scheduler = SerialDispatchQueueScheduler(qos: .default)

    // MARK: - Setup

    init(
        app: AppProtocol = resolve(),
        client: KYCClientAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.app = app
        self.client = client
        self.featureFlagsService = featureFlagsService
        self.analyticsRecorder = analyticsRecorder

        let cache: AnyCache<Key, KYC.UserTiers> = InMemoryCache(
            configuration: .onLoginLogoutKYCChanged(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 180)
        ).eraseToAnyCache()
        self.cachedTiers = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client.tiers()
            }
        )
    }

    func fetchTiers() -> AnyPublisher<KYC.UserTiers, Nabu.Error> {
        cachedTiers.get(key: Key(), forceFetch: false)
    }

    func fetchOverview() -> AnyPublisher<KYCLimitsOverview, Nabu.Error> {
        fetchTiers()
            .zip(
                client.fetchLimitsOverview()
            )
            .map { tiers, rawOverview -> KYCLimitsOverview in
                KYCLimitsOverview(tiers: tiers, features: rawOverview.limits)
            }
            .eraseToAnyPublisher()
    }
}
