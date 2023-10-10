// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import ComposableArchitectureExtensions
import SwiftUI
import XCTest

@MainActor
final class PrefetchingTests: XCTestCase {

    private let scheduler = DispatchQueue.test

    // MARK: - Mocks

    struct TestReducer: Reducer {
        let mainQueue: AnySchedulerOf<DispatchQueue>

        struct State: Equatable {
            var prefetching = PrefetchingState(debounce: 0.5)
        }

        enum Action: Equatable {
            case prefetching(PrefetchingAction)

            case updateValidIndices(Range<Int>)
        }

        var body: some Reducer<State, Action> {
            Scope<State, Action, PrefetchingReducer>(
                state: \State.prefetching,
                action: /Action.prefetching
            ) {
                PrefetchingReducer(mainQueue: mainQueue)
            }

            Reduce { state, action in
                switch action {
                case .updateValidIndices(let range):
                    state.prefetching.validIndices = range
                    return .none
                default:
                    return .none
                }
            }
        }
    }

    // MARK: - Tests

    func testPrefetchingDebounce() async {
        let store = TestStore(
            initialState: TestReducer.State(),
            reducer: { TestReducer(mainQueue: scheduler.eraseToAnyScheduler()) }
        )

        await store.send(.prefetching(.onAppear(index: 0))) {
            $0.prefetching.seen = [0]
        }

        await store.send(.prefetching(.onAppear(index: 1))) {
            $0.prefetching.seen = [0, 1]
        }

        // Shorter than the debounce
        await scheduler.advance(by: 0.25)
        // To the debounce
        await scheduler.advance(by: 0.25)

        await store.receive(.prefetching(.fetchIfNeeded))

        await store.receive(.prefetching(.fetch(indices: [0, 1]))) {
            $0.prefetching.seen = [0, 1]
            $0.prefetching.fetchedIndices = [0, 1]
        }
    }

    func testMarginsOverValidIndices() async {
        let allIndices = 0..<10
        let visible = 2
        let expectedIndicies = Set(allIndices)

        let store = TestStore(
            initialState: .init(),
            reducer: { TestReducer(mainQueue: scheduler.eraseToAnyScheduler()) }
        )

        await store.send(.updateValidIndices(allIndices)) {
            $0.prefetching.validIndices = allIndices
        }

        await store.send(.prefetching(.onAppear(index: visible))) {
            $0.prefetching.seen = [visible]
        }

        await scheduler.advance(by: 0.5)

        await store.receive(.prefetching(.fetchIfNeeded))

        await store.receive(.prefetching(.fetch(indices: expectedIndicies))) {
            $0.prefetching.fetchedIndices = expectedIndicies
        }
    }

    func testMarginsUnderValidIndices() async {
        let allIndices = 0..<50
        let visible = 30
        let expectedIndices = Set(20..<41)

        let store = TestStore(
            initialState: .init(),
            reducer: { TestReducer(mainQueue: scheduler.eraseToAnyScheduler()) }
        )

        await store.send(.updateValidIndices(allIndices)) {
            $0.prefetching.validIndices = allIndices
        }

        await store.send(.prefetching(.onAppear(index: visible))) {
            $0.prefetching.seen = [visible]
        }

        await scheduler.advance(by: 0.5)

        await store.receive(.prefetching(.fetchIfNeeded))

        await store.receive(.prefetching(.fetch(indices: Set(expectedIndices)))) {
            $0.prefetching.fetchedIndices = Set(expectedIndices)
        }
    }

    func testRequeue() async {
        let allIndices = 0..<10
        let visible = 2
        let expectedIndices = Set(allIndices)
        let debounce: DispatchQueue.SchedulerTimeType.Stride = 0.5

        let store = TestStore(
            initialState: .init(
                prefetching: PrefetchingState(
                    debounce: debounce,
                    fetchMargin: 10,
                    validIndices: allIndices
                )
            ),
            reducer: { TestReducer(mainQueue: scheduler.eraseToAnyScheduler()) }
        )

        await store.send(.prefetching(.onAppear(index: visible))) {
            $0.prefetching.seen = [visible]
        }

        await scheduler.advance(by: debounce)

        await store.receive(.prefetching(.fetchIfNeeded))

        await store.receive(.prefetching(.fetch(indices: expectedIndices))) {
            $0.prefetching.fetchedIndices = expectedIndices
        }

        // Fail indices 4 and 6

        let requeue: Set<Int> = [4, 6]
        await store.send(.prefetching(.requeue(indices: requeue))) {
            $0.prefetching.fetchedIndices = expectedIndices.subtracting(requeue)
        }

        // Ensure they're re-fetched after debounce

        await scheduler.advance(by: debounce)

        await store.receive(.prefetching(.fetchIfNeeded))

        await store.receive(.prefetching(.fetch(indices: requeue))) {
            $0.prefetching.fetchedIndices = expectedIndices
        }
    }
}
