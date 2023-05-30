// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import FeatureWalletConnectDomain
import UIKit
import WalletConnectSwift

struct WalletConnectEventEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let onComplete: (_ validate: Bool) -> Void
    let service: WalletConnectServiceAPI
    let router: WalletConnectRouterAPI
    let analyticsEventRecorder: AnalyticsEventRecorderAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        service: WalletConnectServiceAPI,
        router: WalletConnectRouterAPI,
        analyticsEventRecorder: AnalyticsEventRecorderAPI,
        onComplete: @escaping (_ validate: Bool) -> Void
    ) {
        self.mainQueue = mainQueue
        self.onComplete = onComplete
        self.service = service
        self.router = router
        self.analyticsEventRecorder = analyticsEventRecorder
    }
}

let walletConnectEventReducer = Reducer.combine(
    Reducer<
        WalletConnectEventState,
        WalletConnectEventAction,
        WalletConnectEventEnvironment
    > { state, action, env in
        switch action {
        case .accept:
            env.onComplete(true)
            return .none
        case .close:
            env.onComplete(false)
            return .none
        case .disconnect:
            env.service.disconnect(state.session)
            return EffectTask(value: .close)
        case .openWebsite:
            env.router.openWebsite(for: state.session.dAppInfo.peerMeta)
            return .none
        }
    }
)
.analytics()

// MARK: - Private

extension Reducer where
    Action == WalletConnectEventAction,
    State == WalletConnectEventState,
    Environment == WalletConnectEventEnvironment
{
    /// Helper function for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                WalletConnectEventState,
                WalletConnectEventAction,
                WalletConnectEventEnvironment
            > { state, action, env in
                guard let event = state.analyticsEvent(for: action) else {
                    return .none
                }
                return .fireAndForget {
                    env.analyticsEventRecorder.record(event: event)
                }
            }
        )
    }
}
