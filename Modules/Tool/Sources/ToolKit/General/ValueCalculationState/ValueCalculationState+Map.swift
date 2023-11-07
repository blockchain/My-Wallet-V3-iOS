// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ValueCalculationState {
    public func mapValue<TargetValue>(_ map: (Value) -> TargetValue) -> ValueCalculationState<TargetValue> {
        switch self {
        case .calculating:
            .calculating
        case .invalid(.empty):
            .invalid(.empty)
        case .invalid(.valueCouldNotBeCalculated):
            .invalid(.valueCouldNotBeCalculated)
        case .invalid(.ux(let ux)):
            .invalid(.ux(ux))
        case .value(let value):
            .value(map(value))
        }
    }
}
