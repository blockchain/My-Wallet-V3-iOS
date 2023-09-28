// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import Foundation
import UIKit


public struct ReferFriendReducer: ReducerProtocol {

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

    public var body: some ReducerProtocol<State, Action> {
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

                return .merge(
                    .fireAndForget { [referralCode = state.referralInfo.code] in
                        UIPasteboard.general.string = referralCode
                    },
                    EffectTask(value: .onCopyReturn)
                        .delay(
                            for: 2,
                            scheduler: mainQueue
                        )
                        .eraseToEffect()
                )
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

struct ReferFriendAnalytics: ReducerProtocol {

    typealias Action = ReferFriendAction
    typealias State = ReferFriendState

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            guard let event = state.analyticsEvent(for: action) else {
                return .none
            }
            return .fireAndForget {
                analyticsRecorder.record(event: event)
            }
        }
    }
}
