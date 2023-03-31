// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import FeatureWalletConnectDomain
import Localization
import UIComponentsKit
import UIKit
import WalletConnectSwift

import struct MetadataKit.WalletConnectSession

struct DAppListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let onComplete: (_ validate: Bool) -> Void
    let sessionRepository: SessionRepositoryAPI
    let router: WalletConnectRouterAPI
    let analyticsEventRecorder: AnalyticsEventRecorderAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        router: WalletConnectRouterAPI,
        sessionRepository: SessionRepositoryAPI,
        analyticsEventRecorder: AnalyticsEventRecorderAPI,
        onComplete: @escaping (_ validate: Bool) -> Void
    ) {
        self.mainQueue = mainQueue
        self.onComplete = onComplete
        self.sessionRepository = sessionRepository
        self.router = router
        self.analyticsEventRecorder = analyticsEventRecorder
    }
}

public struct DAppListState: Equatable {
    typealias LocalizedString = LocalizationConstants.WalletConnect.List

    struct DAppViewState: Equatable, Identifiable {
        var id: String
        let imageResource: ImageResource?
        let name: String
        let domain: String
    }

    var sessions: [WalletConnectSession] = []
    var title = String(format: LocalizedString.connectedAppsCount, "0")
}

extension DAppListState.DAppViewState {
    init(session: WalletConnectSession) {
        let image: ImageResource?
        if let icon = session.dAppInfo.peerMeta.icons.first,
           let url = URL(string: icon)
        {
            image = .remote(url: url)
        } else {
            image = nil
        }

        id = session.dAppInfo.peerId
        imageResource = image
        name = session.dAppInfo.peerMeta.name

        if let url = URL(string: session.dAppInfo.peerMeta.url) {
            domain = url.host ?? ""
        } else {
            domain = session.dAppInfo.peerMeta.url
        }
    }
}

extension WalletConnectSession: Identifiable {
    public var id: String { url }
}

public enum DAppListAction: Equatable {
    case onAppear
    case loadSessions
    case showSessionDetails(WalletConnectSession)
    case close
    case didReceiveSessions(Result<[WalletConnectSession], Never>)
}

let dAppListReducer = Reducer.combine(
    Reducer<
        DAppListState,
        DAppListAction,
        DAppListEnvironment
    > { state, action, env in
        switch action {
        case .onAppear:
            return EffectTask(value: DAppListAction.loadSessions)
        case .loadSessions:
            return env.sessionRepository
                .retrieve()
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(DAppListAction.didReceiveSessions)
        case .didReceiveSessions(let result):
            if case .success(let sessions) = result {
                state.sessions = sessions
                if sessions.count == 1 {
                    state.title = DAppListState.LocalizedString.connectedAppCount
                } else {
                    state.title = String(
                        format: DAppListState.LocalizedString.connectedAppsCount,
                        String(sessions.count)
                    )
                }
            }
            return .none
        case .showSessionDetails(let session):
            return env.router
                .showSessionDetails(session: session)
                .catchToEffect()
                .delay(for: .milliseconds(500), scheduler: env.mainQueue)
                .map(DAppListAction.loadSessions)
                .eraseToEffect()
        case .close:
            env.onComplete(false)
            return .none
        }
    }
)
.analytics()

// MARK: - Private

extension Reducer where
    Action == DAppListAction,
    State == DAppListState,
    Environment == DAppListEnvironment
{
    /// Helper function for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                DAppListState,
                DAppListAction,
                DAppListEnvironment
            > { _, action, env in
                switch action {
                case .onAppear:
                    return .fireAndForget {
                        env
                            .analyticsEventRecorder
                            .record(event: AnalyticsEvents.New.WalletConnect.connectedDappsListViewed)
                    }
                case .showSessionDetails(let session):
                    return .fireAndForget {
                        env.analyticsEventRecorder
                            .record(event: AnalyticsEvents.New.WalletConnect
                                .connectedDappClicked(
                                    appName: session.dAppInfo.peerMeta.name,
                                    origin: .appsList
                                ))
                    }
                default:
                    return .none
                }
            }
        )
    }
}
