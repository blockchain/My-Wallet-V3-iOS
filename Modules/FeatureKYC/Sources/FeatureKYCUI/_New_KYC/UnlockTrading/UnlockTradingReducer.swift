// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import PlatformKit

private typealias Events = AnalyticsEvents.New.KYC

struct UnlockTradingState: Equatable {
    let currentUserTier: KYC.Tier
}

enum UnlockTradingAction: Equatable, BindableAction {
    case binding(BindingAction<UnlockTradingState>)
    case closeButtonTapped
    case unlockButtonTapped(KYC.Tier)
}

struct UnlockTradingReducer: ReducerProtocol {

    typealias State = UnlockTradingState
    typealias Action = UnlockTradingAction

    let dismiss: () -> Void
    let unlock: (KYC.Tier) -> Void
    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .fireAndForget {
                    dismiss()
                }

            case .unlockButtonTapped(let requiredTier):
                return .fireAndForget {
                    unlock(requiredTier)
                }

            case .binding:
                return .none
            }
        }
        UnlockTradingAnalyticsReducer(analyticsRecorder: analyticsRecorder)
    }
}

// MARK: - Analytics

struct UnlockTradingAnalyticsReducer: ReducerProtocol {

    typealias State = UnlockTradingState
    typealias Action = UnlockTradingAction

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .closeButtonTapped:
                return .none

            case .unlockButtonTapped:
                let userTier = state.currentUserTier
                return .fireAndForget {
                    analyticsRecorder.record(
                        event: Events.tradingLimitsGetVerifiedCTAClicked(
                            tier: userTier.rawValue
                        )
                    )
                }
            }
        }
    }
}

// MARK: - SwiftUI Preview Helpers

extension UnlockTradingReducer {

    static let preview = UnlockTradingReducer(
        dismiss: {},
        unlock: { _ in },
        analyticsRecorder: NoOpAnalyticsRecorder()
    )
}
