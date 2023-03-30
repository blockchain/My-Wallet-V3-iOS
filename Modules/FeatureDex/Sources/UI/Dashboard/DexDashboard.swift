// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import Foundation
import Localization
import MoneyKit
import SwiftUI

@available(iOS 15, *)
public struct DexDashboard: ReducerProtocol {

    let app: AppProtocol
    let balances: () -> AnyPublisher<DelegatedCustodyBalances, Error>

    public init(
        app: AppProtocol,
        balances: @escaping () -> AnyPublisher<DelegatedCustodyBalances, Error>
    ) {
        self.app = app
        self.balances = balances
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.main, action: /Action.mainAction) { () -> DexMain in
            DexMain(app: app, balances: balances)
        }
        Scope(state: \.intro, action: /Action.introAction) { () -> DexIntro in
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
            }
        }
    }
}

@available(iOS 15, *)
extension DexDashboard {
    public struct State: Equatable {
        var showIntro: Bool
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

@available(iOS 15, *)
extension DexDashboard {
    public enum Action: Equatable {
        case onAppear
        case setIntro(isPresented: Bool)
        case mainAction(DexMain.Action)
        case introAction(DexIntro.Action)
    }
}
