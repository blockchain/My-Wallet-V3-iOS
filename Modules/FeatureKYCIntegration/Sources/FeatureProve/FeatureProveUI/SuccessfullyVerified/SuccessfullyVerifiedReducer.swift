// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import DIKit
import Errors
import FeatureProveDomain
import Localization

struct SuccessfullyVerified: ReducerProtocol {
    private typealias LocalizedString = LocalizationConstants.SuccessfullyVerified

    let completion: () -> Void

    init(
        completion: @escaping () -> Void
    ) {
        self.completion = completion
    }

    enum Action: Equatable {
        case onAppear
        case onClose
        case onFinish
    }

    struct State: Equatable {
        var title: String = LocalizedString.title
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none

            case .onFinish:
                return .fireAndForget {
                    completion()
                }

            case .onClose:
                return .fireAndForget {
                    completion()
                }
            }
        }
    }
}

extension SuccessfullyVerified {

    static func preview() -> SuccessfullyVerified {
        SuccessfullyVerified(
            completion: {}
        )
    }
}
