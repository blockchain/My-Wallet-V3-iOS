// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import Foundation
import UIKit

public struct ReferFriendReducer: Reducer {

    public typealias State = ReferFriendState
    public typealias Action = ReferFriendAction

    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let analyticsRecorder: AnalyticsEventRecorderAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.mainQueue = mainQueue
        self.analyticsRecorder = analyticsRecorder
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .onShareTapped:
                state.isShareModalPresented = true
                return .none

            case .onShowRefferalTapped:
                state.isShowReferralViewPresented = true
                return .none

            case .onCopyReturn:
                state.codeIsCopied = false
                return .none

            case .binding:
                return .none

            case .onCopyTapped:
                state.codeIsCopied = true
                UIPasteboard.general.string = state.referralInfo.code
                return .run { send in
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
                    await send(.onCopyReturn)
                }
            }
        }
        ReferFriendAnalytics(analyticsRecorder: analyticsRecorder)
    }
}

// MARK: - Analytics Extensions

extension ReferFriendState {
    func analyticsEvent(for action: ReferFriendAction) -> AnalyticsEvent? {
        switch action {
        case .onAppear:
            return AnalyticsEvents.New.Referral.viewReferralsPage(campaign_id: referralInfo.code)

        case .onCopyTapped:
            return AnalyticsEvents.New.Referral.referralCodeCopied(campaign_id: referralInfo.code)

        case .onShareTapped:
            return AnalyticsEvents.New.Referral.shareReferralsCode(campaign_id: referralInfo.code)

        default:
            return nil
        }
    }
}

struct ReferFriendAnalytics: Reducer {

    typealias Action = ReferFriendAction
    typealias State = ReferFriendState

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            guard let event = state.analyticsEvent(for: action) else {
                return .none
            }
            analyticsRecorder.record(event: event)
            return .none
        }
    }
}
