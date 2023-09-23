// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationDomain
import ToolKit

public enum ResetAccountFailureAction: Equatable {
    public enum URLContent {
        case support
        case learnMore

        var url: URL? {
            switch self {
            case .support:
                return URL(string: Constants.SupportURL.ResetAccount.recoveryFailureSupport)
            case .learnMore:
                return URL(string: Constants.SupportURL.ResetAccount.learnMore)
            }
        }
    }

    case open(urlContent: URLContent)
    case none
}

struct ResetAccountFailureState: Equatable {}

struct ResetAccountFailureReducer: ReducerProtocol {

    typealias State = ResetAccountFailureState
    typealias Action = ResetAccountFailureAction

    let externalAppOpener: ExternalAppOpener

    init(
        externalAppOpener: ExternalAppOpener
    ) {
        self.externalAppOpener = externalAppOpener
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .open(let urlContent):
                guard let url = urlContent.url else {
                    return .none
                }
                externalAppOpener.open(url)
                return .none
            case .none:
                return .none
            }
        }
    }
}
