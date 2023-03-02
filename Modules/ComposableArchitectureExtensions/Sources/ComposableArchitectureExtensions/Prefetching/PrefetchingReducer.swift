// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import Foundation

public struct PrefetchingReducer: ReducerProtocol {
    let mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }

    public typealias State = PrefetchingState
    public typealias Action = PrefetchingAction

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .onAppear(index: let index):
                state.seen.insert(index)
                return Effect(value: .fetchIfNeeded)
                    .debounce(id: FetchId(), for: state.debounce, scheduler: mainQueue)

            case .requeue(indices: let indices):
                state.fetchedIndices.subtract(indices)
                return Effect(value: .fetchIfNeeded)
                    .debounce(id: FetchId(), for: state.debounce, scheduler: mainQueue)

            case .fetchIfNeeded:
                guard let (min, max) = state.seen.minAndMax() else {
                    return .none
                }

                var range: Range<Int> = min..<(max + 1)

                if let validIndices = state.validIndices {
                    range = range.expanded(by: state.fetchMargin).clamped(to: validIndices)
                }

                let indicesToFetch = Set(range).subtracting(state.fetchedIndices)
                if indicesToFetch.isEmpty {
                    return .none
                } else {
                    return Effect(
                        value: .fetch(
                            indices: indicesToFetch
                        )
                    )
                }

            case .fetch(indices: let indices):
                state.fetchedIndices.formUnion(indices)
                return .none
            }
        }
    }
}


private struct FetchId: Hashable {}

extension Range where Bound: AdditiveArithmetic {

    /// Returns a copy of this range, extended outwards by the margin in both directions.
    ///
    /// For example:
    ///
    ///     let x: Range = 10..<20
    ///     print(x.expanded(by: 10))
    ///     // Prints "0..<30"
    func expanded(by margin: Bound) -> Self {
        (lowerBound - margin)..<(upperBound + margin)
    }
}
