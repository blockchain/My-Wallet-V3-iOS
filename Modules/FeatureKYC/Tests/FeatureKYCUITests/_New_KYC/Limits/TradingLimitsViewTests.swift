// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import ComposableArchitecture
import ComposableNavigation
import Errors
@testable import FeatureKYCUI
import PlatformKit
import TestKit
import XCTest

@MainActor final class TradingLimitsViewTests: XCTestCase {

    struct RecordedInvocations {
        var close: [Void] = []
        var openURL: [URL] = []
        var presentKYC: [KYC.Tier] = []
    }

    private var testStore: TestStore<
        TradingLimitsState,
        TradingLimitsAction
    >!
    private let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    private var recordedInvocations = RecordedInvocations()
    private var stubOverview = KYCLimitsOverview(
        tiers: .init(
            tiers: [
                .init(tier: .verified, state: .pending)
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

    func test_initial_load_success() async throws {
        await testStore.send(.fetchLimits) {
            $0.loading = true
        }
        await testScheduler.advance()
        await testStore.receive(.didFetchLimits(.success(stubOverview))) { [stubOverview] in
            $0.loading = false
            $0.userTiers = stubOverview.tiers
            $0.unlockTradingState = UnlockTradingState(currentUserTier: stubOverview.tiers.latestApprovedTier)
            $0.featuresList = LimitedFeaturesListState(
                features: stubOverview.features,
                kycTiers: stubOverview.tiers
            )
        }
    }

    func test_initial_load_failure() async throws {
        resetStore(failCalls: true)
        await testStore.send(.fetchLimits) {
            $0.loading = true
        }
        await testScheduler.advance(by: .seconds(2))
        await testStore.receive(.didFetchLimits(.failure(Nabu.Error.unknown))) {
            $0.loading = false
            $0.featuresList = LimitedFeaturesListState(
                features: [],
                kycTiers: .init(tiers: [])
            )
        }
    }

    func test_initial_load_emptyResult() async throws {
        resetOverviewForEmptyState()
        await testStore.send(.fetchLimits) {
            $0.loading = true
        }
        await testScheduler.advance(by: .seconds(2))
        await testStore.receive(.didFetchLimits(.success(stubOverview))) { [stubOverview] in
            $0.loading = false
            $0.userTiers = stubOverview.tiers
            $0.unlockTradingState = UnlockTradingState(currentUserTier: stubOverview.tiers.latestApprovedTier)
            $0.featuresList = LimitedFeaturesListState(
                features: stubOverview.features,
                kycTiers: stubOverview.tiers
            )
        }
    }

    func test_close() async throws {
        await testStore.send(.close)
        XCTAssertEqual(recordedInvocations.close.count, 1)
    }

    func test_present_support_center() async throws {
        await testStore.send(.listAction(.supportCenterLinkTapped))
        XCTAssertEqual(recordedInvocations.openURL, [.customerSupport])
    }

    func test_apply_for_gold() async throws {
        await testStore.send(.listAction(.verify))
        XCTAssertEqual(recordedInvocations.presentKYC, [.verified])
    }

    func test_view_tiers() async throws {
        await testStore.send(.listAction(.viewTiersTapped))
        await testStore.receive(.listAction(.enter(into: .viewTiers, context: .none))) {
            $0.featuresList.route = .init(route: .viewTiers, action: .enterInto(.none))
        }
    }

    func test_view_tiers_close_modal() async throws {
        await testStore.send(.listAction(.tiersStatusViewAction(.close)))
        await testStore.receive(.listAction(.dismiss()))
    }

    func test_presentKYC_verified() async throws {
        XCTAssertEqual(stubOverview.tiers.latestApprovedTier, .unverified)
        await testStore.send(.didFetchLimits(.success(stubOverview))) { [stubOverview] in
            $0.loading = false
            $0.userTiers = stubOverview.tiers
            $0.unlockTradingState = UnlockTradingState(currentUserTier: stubOverview.tiers.latestApprovedTier)
            $0.featuresList = LimitedFeaturesListState(
                features: stubOverview.features,
                kycTiers: stubOverview.tiers
            )
        }
        await testStore.send(.listAction(.tiersStatusViewAction(.tierTapped(.verified))))
        XCTAssertEqual(recordedInvocations.presentKYC, [.verified])
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
            reducer: {
                TradingLimitsReducer(
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
            }
        )
    }

    func resetOverviewForEmptyState() {
        stubOverview = KYCLimitsOverview(
            tiers: .init(
                tiers: [
                    .init(tier: .verified, state: .pending)
                ]
            ),
            features: []
        )
    }
}
