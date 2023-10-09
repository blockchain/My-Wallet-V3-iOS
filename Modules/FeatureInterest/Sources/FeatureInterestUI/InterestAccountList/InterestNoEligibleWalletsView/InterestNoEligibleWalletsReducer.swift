// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureInterestDomain
import Foundation
import PlatformKit

struct InterestNoEligibleWalletsReducer: ReducerProtocol {
    
    typealias State = InterestNoEligibleWalletsState
    typealias Action = InterestNoEligibleWalletsAction

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .startBuyTapped:
                state.isRoutingToBuy = true
                return EffectTask(value: .dismissNoEligibleWalletsScreen)
            case .startBuyOnDismissalIfNeeded:
                if state.isRoutingToBuy {
                    return EffectTask(value: .startBuyAfterDismissal(state.cryptoCurrency))
                }
                return .none
            case .dismissNoEligibleWalletsScreen,
                 .startBuyAfterDismissal:
                return .none
            }
        }
    }
}
