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

    /// Fetches the Simplified Due Diligence Eligibility Status returning the whole response
    func simplifiedDueDiligenceEligibility(
        for tier: KYC.Tier
    ) -> AnyPublisher<SimplifiedDueDiligenceResponse, Never>

    /// Fetches Simplified Due Diligence Eligibility Status
    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<Bool, Never>

    /// Fetches Simplified Due Diligence Eligibility Status
    func checkSimplifiedDueDiligenceEligibility(
        for tier: KYC.Tier
    ) -> AnyPublisher<Bool, Never>

    /// Fetches the Simplified Due Diligence Verification Status. It pools the API until a valid result is available. If the check fails, it returns `false`.
    func checkSimplifiedDueDiligenceVerification(
        for tier: KYC.Tier,
        pollUntilComplete: Bool
    ) -> AnyPublisher<Bool, Never>

    /// Checks if the current user is SDD Verified
    func checkSimplifiedDueDiligenceVerification(
        pollUntilComplete: Bool
    ) -> AnyPublisher<Bool, Never>

    /// Fetches the KYC overview (features and limits) for the logged-in user
    func fetchOverview() -> AnyPublisher<KYCLimitsOverview, Nabu.Error>
}

extension KYCTiersServiceAPI {

    /// Returnes whether or not the user is Tier 2 approved.
    public var isKYCVerified: AnyPublisher<Bool, Never> {
        fetchTiers()
            .map(\.isTier2Approved)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    /// Returns whether or not the user can make purchases
    public var canPurchaseCrypto: AnyPublisher<Bool, Never> {
        fetchTiers()
            .zip(
                checkSimplifiedDueDiligenceVerification(pollUntilComplete: false)
                    .setFailureType(to: Nabu.Error.self)
            )
            .map { userTiers, isSDDVerified -> Bool in
                // users can make purchases if they are at least Tier 2 approved or Tier 3 (Tier 1 and SDD Verified)
                userTiers.canPurchaseCrypto(isSDDVerified: isSDDVerified)
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

    private let sddCache: CachedValueNew<
        KYC.Tier,
        SimplifiedDueDiligenceResponse,
        Never
    >

    private let sddVerificationCache: CachedValueNew<
        KYC.Tier,
        SimplifiedDueDiligenceVerificationResponse,
        Never
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

        self.sddCache = CachedValueNew(
            cache: InMemoryCache<KYC.Tier, SimplifiedDueDiligenceResponse>(
                configuration: .onLoginLogoutKYCChanged(),
                refreshControl: PeriodicCacheRefreshControl(refreshInterval: 180)
            )
            .eraseToAnyCache(),
            fetch: { tier in
                client.checkSimplifiedDueDiligenceEligibility()
                    .replaceError(with: SimplifiedDueDiligenceResponse(eligible: false, tier: tier.rawValue))
                    .eraseToAnyPublisher()
            }
        )

        self.sddVerificationCache = CachedValueNew(
            cache: InMemoryCache<KYC.Tier, SimplifiedDueDiligenceVerificationResponse>(
                configuration: .onLoginLogoutKYCChanged(),
                refreshControl: PeriodicCacheRefreshControl(refreshInterval: 180)
            )
            .eraseToAnyCache(),
            fetch: { _ in
                client.checkSimplifiedDueDiligenceVerification()
                    .replaceError(with: SimplifiedDueDiligenceVerificationResponse(verified: false, taskComplete: true))
                    .eraseToAnyPublisher()
            }
        )
    }

    func fetchTiers() -> AnyPublisher<KYC.UserTiers, Nabu.Error> {
        cachedTiers.get(key: Key(), forceFetch: false)
    }

    func simplifiedDueDiligenceEligibility(for tier: KYC.Tier) -> AnyPublisher<SimplifiedDueDiligenceResponse, Never> {
        guard tier != .tier2 else {
            // Tier2 (Gold) verified users should be treated as SDD eligible
            return .just(SimplifiedDueDiligenceResponse(eligible: true, tier: tier.rawValue))
        }
        return featureFlagsService.isEnabled(.sddEnabled)
            .zip(
                app.publisher(for: blockchain.app.configuration.kyc.sdd.cache.is.enabled)
                    .replaceError(with: true)
                    .prefix(1)
            )
            .flatMap { [client, sddCache] sddEnabled, cacheEnabled -> AnyPublisher<SimplifiedDueDiligenceResponse, Never> in
                guard sddEnabled else {
                    return .just(SimplifiedDueDiligenceResponse(eligible: false, tier: KYC.Tier.tier0.rawValue))
                }
                if cacheEnabled {
                    return sddCache.get(key: tier)
                } else {
                    return client.checkSimplifiedDueDiligenceEligibility()
                        .replaceError(with: SimplifiedDueDiligenceResponse(eligible: false, tier: tier.rawValue))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<Bool, Never> {
        featureFlagsService.isEnabled(.sddEnabled)
            .flatMap { [cachedTiers, simplifiedDueDiligenceEligibility] sddEnabled -> AnyPublisher<Bool, Never> in
                guard sddEnabled else {
                    return .just(false)
                }
                return cachedTiers.get(key: Key())
                    .flatMap { userTiers -> AnyPublisher<Bool, Nabu.Error> in
                        simplifiedDueDiligenceEligibility(userTiers.latestApprovedTier)
                            .map(\.eligible)
                            .setFailureType(to: Nabu.Error.self)
                            .eraseToAnyPublisher()
                    }
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [analyticsRecorder] isSDDEligible in
                if isSDDEligible {
                    analyticsRecorder.record(event: SDDAnalytics.userIsSddEligible)
                }
            })
            .eraseToAnyPublisher()
    }

    func checkSimplifiedDueDiligenceEligibility(for tier: KYC.Tier) -> AnyPublisher<Bool, Never> {
        simplifiedDueDiligenceEligibility(for: tier)
            .map(\.eligible)
            .eraseToAnyPublisher()
    }

    func checkSimplifiedDueDiligenceVerification(
        for tier: KYC.Tier,
        pollUntilComplete: Bool
    ) -> AnyPublisher<Bool, Never> {
        guard tier != .tier2 else {
            // Tier 2 (Gold) verified users should be treated as SDD verified
            return .just(true)
        }

        return featureFlagsService.isEnabled(.sddEnabled)
            .zip(
                app.publisher(for: blockchain.app.configuration.kyc.sdd.cache.is.enabled)
                    .replaceError(with: true)
                    .prefix(1)
            )
            .flatMap { [sddVerificationCache, client] sddEnabled, cacheEnabled -> AnyPublisher<Bool, Never> in
                guard sddEnabled else {
                    return .just(false)
                }
                return (
                    cacheEnabled
                        ? sddVerificationCache.get(key: tier)
                        : client.checkSimplifiedDueDiligenceVerification()
                            .replaceError(with: SimplifiedDueDiligenceVerificationResponse(verified: false, taskComplete: true))
                            .eraseToAnyPublisher()
                )
                .flatMap { response -> AnyPublisher<Bool, Never> in
                    if response.taskComplete {
                        return .just(response.verified)
                    } else {
                        return client.checkSimplifiedDueDiligenceVerification()
                            .startPolling(until: { response in
                                response.taskComplete || !pollUntilComplete
                            })
                            .replaceError(with: SimplifiedDueDiligenceVerificationResponse(verified: false, taskComplete: true))
                            .map(\.verified)
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [analyticsRecorder] isSDDEligible in
                if isSDDEligible {
                    analyticsRecorder.record(event: SDDAnalytics.userIsSddEligible)
                }
            })
            .eraseToAnyPublisher()
    }

    func checkSimplifiedDueDiligenceVerification(pollUntilComplete: Bool) -> AnyPublisher<Bool, Never> {
        let sddVerificationCheck = checkSimplifiedDueDiligenceVerification(for:pollUntilComplete:)
        return featureFlagsService.isEnabled(.sddEnabled)
            .flatMap { [fetchTiers, sddVerificationCheck] sddEnabled -> AnyPublisher<Bool, Never> in
                guard sddEnabled else {
                    return .just(false)
                }
                return fetchTiers()
                    .flatMap { userTiers -> AnyPublisher<Bool, Nabu.Error> in
                        sddVerificationCheck(userTiers.latestApprovedTier, pollUntilComplete)
                            .setFailureType(to: Nabu.Error.self)
                            .eraseToAnyPublisher()
                    }
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
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

/// Temporary legacy SDD analytics events definition. To be removed after dropping Firebase analytics.
enum SDDAnalytics: AnalyticsEvent {

    case userIsSddEligible

    var type: AnalyticsEventType {
        .firebase
    }

    var name: String {
        "user_is_sdd_eligible"
    }

    var params: [String: Any]? {
        nil
    }
}
