// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Foundation
import Localization
import SwiftUI

public struct DexIntro: ReducerProtocol {

    var app: AppProtocol

    public init (
        app: AppProtocol
    ) {
        self.app = app
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .onAppear:
            return .fireAndForget {
                app.state.set(blockchain.ux.currency.exchange.dex.intro.did.show, to: true)
            }
        case .didChangeStep(let step):
            state.currentStep = step
            return .none
        case .onDismiss:
            return .none
        }
    }

    public struct State: Equatable {

        public enum Step: Hashable, Identifiable {
            public var id: Self { self }

            case welcome
            case swapTokens
            case keepControl
        }

        var currentStep: Step
        let steps: [Step] = [.welcome, .swapTokens, .keepControl]

        public init(currentStep: Step = .welcome) {
            self.currentStep = currentStep
        }
    }

    public enum Action: Equatable {
        case onAppear
        case didChangeStep(State.Step)
        case onDismiss
    }
}

extension DexIntro.State.Step {
    typealias L10n = LocalizationConstants.Dex.Onboarding

    var title: String {
        switch self {
        case .welcome:
            return L10n.Welcome.title
        case .swapTokens:
            return L10n.SwapTokens.title
        case .keepControl:
            return L10n.SwapTokens.title
        }
    }

    var text: String {
        switch self {
        case .welcome:
            return L10n.Welcome.description
        case .swapTokens:
            return L10n.SwapTokens.description
        case .keepControl:
            return L10n.SwapTokens.description
        }
    }

    var image: Image {
        switch self {
        case .welcome:
            return Image("onboarding/welcome", bundle: .module)
        case .swapTokens:
            return Image("onboarding/swap-tokens", bundle: .module)
        case .keepControl:
            return Image("onboarding/keep-control", bundle: .module)
        }
    }
}
