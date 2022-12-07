// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import DIKit
import Errors
import FeatureProveDomain
import Localization

struct SuccessfullyVerified: ReducerProtocol {
    private typealias LocalizedString = LocalizationConstants.SuccessfullyVerified

    let dismissFlow: () -> Void

    init(
        dismissFlow: @escaping () -> Void
    ) {
        self.dismissFlow = dismissFlow
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
                    dismissFlow()
                }

            case .onClose:
                return .fireAndForget {
                    dismissFlow()
                }
            }
        }
    }
}

extension SuccessfullyVerified {

    static func preview() -> SuccessfullyVerified {
        SuccessfullyVerified(
            dismissFlow: {}
        )
    }
}
