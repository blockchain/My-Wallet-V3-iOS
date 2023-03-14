// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import ComposableArchitectureExtensions
import SwiftUI
import XCTest

final class PrefetchingTests: XCTestCase {

    private let scheduler = DispatchQueue.test

    // MARK: - Mocks

    struct TestReducer: ReducerProtocol {
        let mainQueue: AnySchedulerOf<DispatchQueue>

        struct State: Equatable {
            var prefetching = PrefetchingState(debounce: 0.5)
        }

        enum Action: Equatable {
            case prefetching(PrefetchingAction)

            case updateValidIndices(Range<Int>)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: \.prefetching,
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

    func testPrefetchingDebounce() {
        let store = TestStore(
            initialState: TestReducer.State(),
            reducer: TestReducer(mainQueue: scheduler.eraseToAnyScheduler())
        )

        store.send(.prefetching(.onAppear(index: 0))) {
            $0.prefetching.seen = [0]
        }

        store.send(.prefetching(.onAppear(index: 1))) {
            $0.prefetching.seen = [0, 1]
        }

        // Shorter than the debounce
        scheduler.advance(by: 0.25)
        // To the debounce
        scheduler.advance(by: 0.25)

        store.receive(.prefetching(.fetchIfNeeded))

        store.receive(.prefetching(.fetch(indices: [0, 1]))) {
            $0.prefetching.seen = [0, 1]
            $0.prefetching.fetchedIndices = [0, 1]
        }
    }

    func testMarginsOverValidIndices() {
        let allIndices = 0..<10
        let visible = 2
        let expectedIndicies = Set(allIndices)

        let store = TestStore(
            initialState: .init(),
            reducer: TestReducer(mainQueue: scheduler.eraseToAnyScheduler())
        )

        store.send(.updateValidIndices(allIndices)) {
            $0.prefetching.validIndices = allIndices
        }

        store.send(.prefetching(.onAppear(index: visible))) {
            $0.prefetching.seen = [visible]
        }

        scheduler.advance(by: 0.5)

        store.receive(.prefetching(.fetchIfNeeded))

        store.receive(.prefetching(.fetch(indices: expectedIndicies))) {
            $0.prefetching.fetchedIndices = expectedIndicies
        }
    }

    func testMarginsUnderValidIndices() {
        let allIndices = 0..<50
        let visible = 30
        let expectedIndices = Set(20..<41)

        let store = TestStore(
            initialState: .init(),
            reducer: TestReducer(mainQueue: scheduler.eraseToAnyScheduler())
        )

        store.send(.updateValidIndices(allIndices)) {
            $0.prefetching.validIndices = allIndices
        }

        store.send(.prefetching(.onAppear(index: visible))) {
            $0.prefetching.seen = [visible]
        }

        scheduler.advance(by: 0.5)

        store.receive(.prefetching(.fetchIfNeeded))

        store.receive(.prefetching(.fetch(indices: Set(expectedIndices)))) {
            $0.prefetching.fetchedIndices = Set(expectedIndices)
        }
    }

    func testRequeue() {
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
            reducer: TestReducer(mainQueue: scheduler.eraseToAnyScheduler())
        )

        store.send(.prefetching(.onAppear(index: visible))) {
            $0.prefetching.seen = [visible]
        }

        scheduler.advance(by: debounce)

        store.receive(.prefetching(.fetchIfNeeded))

        store.receive(.prefetching(.fetch(indices: expectedIndices))) {
            $0.prefetching.fetchedIndices = expectedIndices
        }

        // Fail indices 4 and 6

        let requeue: Set<Int> = [4, 6]
        store.send(.prefetching(.requeue(indices: requeue))) {
            $0.prefetching.fetchedIndices = expectedIndices.subtracting(requeue)
        }

        // Ensure they're re-fetched after debounce

        scheduler.advance(by: debounce)

        store.receive(.prefetching(.fetchIfNeeded))

        store.receive(.prefetching(.fetch(indices: requeue))) {
            $0.prefetching.fetchedIndices = expectedIndices
        }
    }
}
