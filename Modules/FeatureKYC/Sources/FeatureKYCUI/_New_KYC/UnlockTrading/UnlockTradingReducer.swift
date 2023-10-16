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

struct UnlockTradingReducer: Reducer {

    typealias State = UnlockTradingState
    typealias Action = UnlockTradingAction

    let dismiss: () -> Void
    let unlock: (KYC.Tier) -> Void
    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                dismiss()
                return .none

            case .unlockButtonTapped(let requiredTier):
                unlock(requiredTier)
                return .none

            case .binding:
                return .none
            }
        }
        UnlockTradingAnalyticsReducer(analyticsRecorder: analyticsRecorder)
    }
}

// MARK: - Analytics

struct UnlockTradingAnalyticsReducer: Reducer {

    typealias State = UnlockTradingState
    typealias Action = UnlockTradingAction

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .closeButtonTapped:
                return .none

            case .unlockButtonTapped:
                let userTier = state.currentUserTier
                return .run { _ in
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
