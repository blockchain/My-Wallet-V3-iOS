// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureInterestDomain
import Foundation
import PlatformKit

typealias InterestNoEligibleWalletsReducer = Reducer<
    InterestNoEligibleWalletsState,
    InterestNoEligibleWalletsAction,
    InterestNoEligibleWallletsEnvironment
>

let interestNoEligibleWalletsReducer = InterestNoEligibleWalletsReducer { state, action, _ in
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
