// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import FeatureDexData
import FeatureDexDomain
import Foundation
import MoneyKit
import SwiftUI

public struct DexDashboard: ReducerProtocol {

    let app: AppProtocol

    public init(
        app: AppProtocol
    ) {
        self.app = app
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
    }
}

extension DexDashboard {
    public struct State: Equatable {
        @BindingState var showIntro: Bool
        var main: DexMain.State
        var intro: DexIntro.State

        public init(
            showIntro: Bool = false,
            main: DexMain.State = .init(),
            intro: DexIntro.State = .init()
        ) {
            self.showIntro = showIntro
            self.main = main
            self.intro = intro
        }
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
