// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureInterestDomain
import Foundation
import PlatformKit

struct InterestNoEligibleWalletsReducer: Reducer {

    typealias State = InterestNoEligibleWalletsState
    typealias Action = InterestNoEligibleWalletsAction

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startBuyTapped:
                state.isRoutingToBuy = true
                return Effect.send(.dismissNoEligibleWalletsScreen)
            case .startBuyOnDismissalIfNeeded:
                if state.isRoutingToBuy {
                    return Effect.send(.startBuyAfterDismissal(state.cryptoCurrency))
                }
                return .none
            case .dismissNoEligibleWalletsScreen,
                 .startBuyAfterDismissal:
                return .none
            }
        }
    }
}
