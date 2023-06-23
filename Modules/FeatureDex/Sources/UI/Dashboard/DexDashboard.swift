// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainUI
import DelegatedSelfCustodyDomain
import FeatureDexData
import FeatureDexDomain
import SwiftUI

public struct DexDashboard: ReducerProtocol {

    let app: AppProtocol
    let analyticsRecorder: AnalyticsEventRecorderAPI

    public init(
        app: AppProtocol,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.app = app
        self.analyticsRecorder = analyticsRecorder
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Scope(state: \.main, action: /Action.mainAction) {
            DexMain(app: app)
        }
        Scope(state: \.intro, action: /Action.introAction) {
            DexIntro(app: app)
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return app
                    .publisher(for: blockchain.ux.currency.exchange.dex.intro.did.show, as: Bool.self)
                    .replaceError(with: false)
                    .first()
                    .map { !$0 }
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect(Action.setIntro(isPresented:))
            case .setIntro(let isPresented):
                state.showIntro = isPresented
                return .none
            case .introAction(.onDismiss):
                state.showIntro = false
                return .none
            case .introAction:
                return .none
            case .mainAction:
                return .none
            case .binding:
                return .none
            }
        }
        Scope(state: \.self, action: /Action.self) {
            DexDashboardAnalytics(analyticsRecorder: analyticsRecorder, app: app)
        }
    }
}

extension DexDashboard {
    public struct State: Equatable {
        @BindingState var showIntro: Bool = false
        var main: DexMain.State = .init()
        var intro: DexIntro.State = .init()

        public init() {}
    }
}

extension DexDashboard {
    public enum Action: BindableAction, Equatable {
        case onAppear
        case binding(BindingAction<State>)
        case setIntro(isPresented: Bool)
        case mainAction(DexMain.Action)
        case introAction(DexIntro.Action)
    }
}
