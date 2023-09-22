// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Foundation
import SwiftUI

struct EarnProductCompare: ReducerProtocol {

    private let onDismiss: () -> Void

    init (onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .didChangeStep(let step):
            state.currentStep = step
            return .none
        case .onDismiss:
            return .fireAndForget {
                onDismiss()
            }
        }
    }
}

extension EarnProductCompare {
    struct State: Equatable {
        enum Step: Hashable, Identifiable {
            var id: Self { self }
            case passive
            case staking
            case active
        }

        private let scrollEffectTransitionDistance: CGFloat = 300
        var scrollOffset: CGFloat = 0
        var currentStep: Step
        let steps: [Step]
        let model: [Model]

        init(products: [EarnProduct], model: [Model]?) {
            self.steps = products.compactMap(\.step)
            self.currentStep = steps.first ?? .passive
            self.model = model ?? []
        }

        func highestRate(for product: EarnProduct) -> Double {
            model
                .filter { $0.product == product }
                .map(\.rate)
                .max() ?? 0
        }

        var gradientBackgroundOpacity: Double {
            switch scrollOffset {
            case _ where scrollOffset >= 0:
                return 1
            case _ where scrollOffset <= -scrollEffectTransitionDistance:
                return 0
            default:
                return 1 - Double(scrollOffset / -scrollEffectTransitionDistance)
            }
        }
    }
}

extension EarnProductCompare {
    enum Action: Equatable {
        case didChangeStep(State.Step)
        case onDismiss
    }
}

extension EarnProduct {
    var step: EarnProductCompare.State.Step? {
        switch self {
        case .active:
            return .active
        case .staking:
            return .staking
        case .savings:
            return .passive
        default:
            return nil
        }
    }
}
