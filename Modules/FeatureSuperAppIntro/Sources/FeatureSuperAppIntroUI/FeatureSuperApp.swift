import ComposableArchitecture
import Foundation

public struct FeatureSuperAppIntro: ReducerProtocol {

    public init (onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action, Never> {
        switch action {
        case .didChangeStep(let step):
            state.currentStep = step
            return .none

        case .onDismiss:
            onDismiss()
            return .none
        }
    }

    var onDismiss: () -> Void

    public struct State: Equatable {
        public init(
            flow: Flow = .newUser
        ) {
            self.flow = flow
            self.steps = flow.steps
            self.currentStep = flow.steps.first ?? .welcomeNewUserV1
        }

        public enum Flow: Hashable {
            case existingUser
            case newUser
            case tradingFirst
            case defiFirst

            var steps: [Step] {
                switch self {
                case .newUser:
                    return Step.newUser
                case .existingUser:
                    return Step.existingUser
                case .tradingFirst:
                    return Step.tradingFirst
                case .defiFirst:
                    return Step.defiFirst
                }
            }
        }

        public enum Step: Hashable, Identifiable {
            public var id: Self { self }

            public static let newUser: [Self] = [.welcomeNewUserV1, .tradingAccountV1, .defiWalletV1]
            public static let existingUser: [Self] = [.welcomeExistingUserV1, .tradingAccountV1, .defiWalletV1]
            public static let tradingFirst: [Self] = [.tradingAccountV1, .defiWalletV1]
            public static let defiFirst: [Self] = [.defiWalletV1, .tradingAccountV1]

            // SuperApp v1 with new skin
            case welcomeNewUserV1
            case welcomeExistingUserV1
            case tradingAccountV1
            case defiWalletV1
        }

        private let scrollEffectTransitionDistance: CGFloat = 300

        var scrollOffset: CGFloat = 0
        var currentStep: Step
        var flow: Flow
        var steps: [Step]

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

    public enum Action: Equatable {
        case didChangeStep(State.Step)
        case onDismiss
    }
}
