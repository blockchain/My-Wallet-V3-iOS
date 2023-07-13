// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformUIKit

import BigInt
import BlockchainNamespace
import Combine
import ComposableArchitecture
import MoneyKit
import OrderedCollections
import XCTest

final class PrefillButtonsReducerTests: XCTestCase {

    private var mockMainQueue: ImmediateSchedulerOf<DispatchQueue>!
    private let lastPurchase = FiatValue.create(minor: 900, currency: .USD)
    private let maxLimit = FiatValue.create(minor: 120000, currency: .USD)

    private let baseValueQuickfillConfigurations: [QuickfillConfiguration] = [
        .init(multiplier: 2.0, rounding: 10),
        .init(multiplier: 2.0, rounding: 50),
        .init(multiplier: 2.0, rounding: 100)
    ].map { .baseValue($0) }

    private let balanceQuickfillConfigurations: [QuickfillConfiguration] = [
        .init(multiplier: 0.25, rounding: [1, 10, 25, 100, 500, 1000]),
        .init(multiplier: 0.5, rounding: [1, 10, 25, 100, 500, 1000]),
        .init(multiplier: 0.75, rounding: [1, 10, 25, 100, 500, 1000])
    ].map { .balance($0) }

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.immediate
    }

    func test_swap_stateValues() {
        let state = PrefillButtonsState(
            previousTxAmount: FiatValue.create(minor: 6565, currency: .USD),
            action: .swap,
            maxLimit: maxLimit,
            configurations: balanceQuickfillConfigurations
        )
        XCTAssertEqual(state.previousTxAmount, FiatValue.create(minor: 6565, currency: .USD))
        XCTAssertEqual(state.suggestedValues[0].fiatValue!, FiatValue.create(minor: 30000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[1].fiatValue!, FiatValue.create(minor: 60000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[2].fiatValue!, FiatValue.create(minor: 90000, currency: .USD))
    }

    func test_removing_duplicates_ignoring_size() {
        let suggestions: [QuickfillSuggestion] = [
            .init(majorValue: 1000, size: .small, currency: .GBP),
            .init(majorValue: 1000, size: .medium, currency: .GBP),
            .init(majorValue: 5000, size: .medium, currency: .GBP)
        ]
        let expected: [QuickfillSuggestion] = [
            .init(majorValue: 1000, size: .small, currency: .GBP),
            .init(majorValue: 5000, size: .medium, currency: .GBP)
        ]
        let result = OrderedSet(suggestions)
            .array
        XCTAssertEqual(expected, result)
    }

    func test_buy_stateValues() {
        let state = PrefillButtonsState(
            previousTxAmount: FiatValue.create(minor: 6565, currency: .USD),
            action: .buy,
            maxLimit: maxLimit,
            configurations: baseValueQuickfillConfigurations
        )
        XCTAssertEqual(state.previousTxAmount, FiatValue.create(minor: 6565, currency: .USD))
        XCTAssertEqual(state.suggestedValues[0].fiatValue!, FiatValue.create(minor: 14000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[1].fiatValue!, FiatValue.create(minor: 30000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[2].fiatValue!, FiatValue.create(minor: 60000, currency: .USD))
    }

    func test_buy_stateValues_overMaxLimit() {
        let state = PrefillButtonsState(
            previousTxAmount: FiatValue.create(minor: 110000, currency: .USD),
            maxLimit: maxLimit
        )
        XCTAssertEqual(state.previousTxAmount, FiatValue.create(minor: 110000, currency: .USD))
        XCTAssertTrue(state.suggestedValues.isEmpty)
    }

    @MainActor
    func test_roundingLastPurchase_after_onAppear() async {
        let testStore = TestStore(
            initialState: .init(),
            reducer: PrefillButtons(
                app: App.test,
                lastPurchasePublisher: .just(lastPurchase),
                maxLimitPublisher: .just(maxLimit),
                onValueSelected: { _, _ in }
            )
        )

        let task = await testStore.send(.onAppear)

        let expected = FiatValue.create(minor: 1000, currency: .USD)
        await testStore.receive(.updatePreviousTxAmount(expected)) { state in
            state.previousTxAmount = expected
        }
        await testStore.receive(.updateMaxLimit(maxLimit)) { [maxLimit] state in
            state.maxLimit = maxLimit
        }

        await task.cancel()
    }

    func test_select_triggersEnvironmentClosure() {
        let e = expectation(description: "Closure should be triggered")
        let testStore = TestStore(
            initialState: .init(),
            reducer: PrefillButtons(
                app: App.test,
                lastPurchasePublisher: .just(lastPurchase),
                maxLimitPublisher: .just(maxLimit),
                onValueSelected: { value, _ in
                    XCTAssertEqual(value.currency, .USD)
                    XCTAssertEqual(value.minorAmount, BigInt(123))
                    e.fulfill()
                }
            )
        )

        testStore.send(.select(FiatValue.create(minor: 123, currency: .USD), .small))
        waitForExpectations(timeout: 1)
    }
}
