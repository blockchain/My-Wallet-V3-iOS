// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import ComposableArchitecture
import ComposableNavigation
import Errors
@testable import FeatureKYCUI
import PlatformKit
import TestKit
import XCTest

final class TradingLimitsViewTests: XCTestCase {

    struct RecordedInvocations {
        var close: [Void] = []
        var openURL: [URL] = []
        var presentKYC: [KYC.Tier] = []
    }

    private var testStore: TestStore<
        TradingLimitsState,
        TradingLimitsAction,
        TradingLimitsState,
        TradingLimitsAction,
        TradingLimitsEnvironment
    >!
    private let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    private var recordedInvocations = RecordedInvocations()
    private var stubOverview = KYCLimitsOverview(
        tiers: .init(
            tiers: [
                .init(tier: .tier1, state: .verified),
                .init(tier: .tier2, state: .pending)
            ]
        ),
        features: [
            LimitedTradeFeature(id: .send, enabled: false, limit: nil)
        ]
    )

    override func setUpWithError() throws {
        try super.setUpWithError()
        resetStore()
    }

    override func tearDownWithError() throws {
        testStore = nil
        try super.tearDownWithError()
    }

    func test_initial_load_success() throws {
        testStore.send(.fetchLimits) {
            $0.loading = true
        }
        testScheduler.advance()
        testStore.receive(.didFetchLimits(.success(stubOverview))) { [stubOverview] in
            $0.loading = false
            $0.userTiers = stubOverview.tiers
            $0.unlockTradingState = UnlockTradingState(currentUserTier: stubOverview.tiers.latestApprovedTier)
            $0.featuresList = LimitedFeaturesListState(
                features: stubOverview.features,
                kycTiers: stubOverview.tiers
            )
        }
    }

    func test_initial_load_failure() throws {
        resetStore(failCalls: true)
        testStore.send(.fetchLimits) {
            $0.loading = true
        }
        testScheduler.advance(by: .seconds(2))
        testStore.receive(.didFetchLimits(.failure(Nabu.Error.unknown))) {
            $0.loading = false
            $0.featuresList = LimitedFeaturesListState(
                features: [],
                kycTiers: .init(tiers: [])
            )
        }
    }

    func test_initial_load_emptyResult() throws {
        resetOverviewForEmptyState()
        testStore.send(.fetchLimits) {
            $0.loading = true
        }
        testScheduler.advance(by: .seconds(2))
        testStore.receive(.didFetchLimits(.success(stubOverview))) { [stubOverview] in
            $0.loading = false
            $0.userTiers = stubOverview.tiers
            $0.unlockTradingState = UnlockTradingState(currentUserTier: stubOverview.tiers.latestApprovedTier)
            $0.featuresList = LimitedFeaturesListState(
                features: stubOverview.features,
                kycTiers: stubOverview.tiers
            )
        }
    }

    func test_close() throws {
        testStore.send(.close)
        XCTAssertEqual(recordedInvocations.close.count, 1)
    }

    func test_present_support_center() throws {
        testStore.send(.listAction(.supportCenterLinkTapped))
        XCTAssertEqual(recordedInvocations.openURL, [.customerSupport])
    }

    func test_apply_for_gold() throws {
        testStore.send(.listAction(.applyForGoldTierTapped))
        XCTAssertEqual(recordedInvocations.presentKYC, [.tier2])
    }

    func test_view_tiers() throws {
        testStore.send(.listAction(.viewTiersTapped))
        testStore.receive(.listAction(.enter(into: .viewTiers, context: .none))) {
            $0.featuresList.route = .init(route: .viewTiers, action: .enterInto(.none))
        }
    }

    func test_view_tiers_close_modal() throws {
        testStore.send(.listAction(.tiersStatusViewAction(.close)))
        testStore.receive(.listAction(.dismiss()))
    }

    func test_presentKYC_tier1() throws {
        XCTAssertEqual(stubOverview.tiers.latestApprovedTier, .tier1)
        testStore.send(.didFetchLimits(.success(stubOverview))) { [stubOverview] in
            $0.loading = false
            $0.userTiers = stubOverview.tiers
            $0.unlockTradingState = UnlockTradingState(currentUserTier: stubOverview.tiers.latestApprovedTier)
            $0.featuresList = LimitedFeaturesListState(
                features: stubOverview.features,
                kycTiers: stubOverview.tiers
            )
        }
        testStore.send(.listAction(.tiersStatusViewAction(.tierTapped(.tier1))))
        XCTAssertEqual(recordedInvocations.presentKYC, [])
    }

    func test_presentKYC_tier2() throws {
        XCTAssertEqual(stubOverview.tiers.latestApprovedTier, .tier1)
        testStore.send(.didFetchLimits(.success(stubOverview))) { [stubOverview] in
            $0.loading = false
            $0.userTiers = stubOverview.tiers
            $0.unlockTradingState = UnlockTradingState(currentUserTier: stubOverview.tiers.latestApprovedTier)
            $0.featuresList = LimitedFeaturesListState(
                features: stubOverview.features,
                kycTiers: stubOverview.tiers
            )
        }
        testStore.send(.listAction(.tiersStatusViewAction(.tierTapped(.tier2))))
        XCTAssertEqual(recordedInvocations.presentKYC, [.tier2])
    }

    // MARK: - Helpers

    func resetStore(failCalls: Bool = false) {
        testStore = .init(
            initialState: TradingLimitsState(
                loading: false,
                userTiers: nil,
                featuresList: LimitedFeaturesListState(
                    features: [],
                    kycTiers: .init(tiers: [])
                )
            ),
            reducer: tradingLimitsReducer,
            environment: TradingLimitsEnvironment(
                close: { [weak self] in
                    self?.recordedInvocations.close.append(())
                },
                openURL: { [weak self] url in
                    self?.recordedInvocations.openURL.append(url)
                },
                presentKYCFlow: { tier in
                    self.recordedInvocations.presentKYC.append(tier)
                },
                fetchLimitsOverview: { [unowned self] in
                    guard failCalls else {
                        return .just(stubOverview)
                    }
                    return .failure(Nabu.Error.unknown)
                },
                analyticsRecorder: MockAnalyticsRecorder(),
                mainQueue: testScheduler.eraseToAnyScheduler()
            )
        )
    }

    func resetOverviewForEmptyState() {
        stubOverview = KYCLimitsOverview(
            tiers: .init(
                tiers: [
                    .init(tier: .tier1, state: .verified),
                    .init(tier: .tier2, state: .pending)
                ]
            ),
            features: []
        )
    }
}
