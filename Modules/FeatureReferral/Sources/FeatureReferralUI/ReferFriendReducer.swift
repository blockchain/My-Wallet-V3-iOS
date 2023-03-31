// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import UIKit

public enum ReferFriendModule {}

extension ReferFriendModule {
    public static var reducer: Reducer<ReferFriendState, ReferFriendAction, ReferFriendEnvironment> {
        .init { state, action, environment in
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
                            scheduler: environment.mainQueue
                        )
                        .eraseToEffect()
                )
            }
        }
        .binding()
        .analytics()
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

extension Reducer where
    Action == ReferFriendAction,
    State == ReferFriendState,
    Environment == ReferFriendEnvironment
{
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                ReferFriendState,
                ReferFriendAction,
                ReferFriendEnvironment
            > { state, action, env in
                guard let event = state.analyticsEvent(for: action) else {
                    return .none
                }
                return .fireAndForget {
                    env.analyticsRecorder.record(event: event)
                }
            }
        )
    }
}
