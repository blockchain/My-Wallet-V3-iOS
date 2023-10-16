// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import FeatureAuthenticationDomain

public enum ResetAccountWarningAction: Equatable {
    case onDisappear
    case retryButtonTapped
    case continueResetButtonTapped
}

struct ResetAccountWarningState: Equatable {}

struct ResetAccountWarningReducer: Reducer {

    typealias State = ResetAccountWarningState
    typealias Action = ResetAccountWarningAction

    let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI) {
        self.analyticsRecorder = analyticsRecorder
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onDisappear:
                analyticsRecorder.record(
                    event: .resetAccountCancelled
                )
                return .none
            case .retryButtonTapped:
                return .none
            case .continueResetButtonTapped:
                return .none
            }
        }
    }
}
