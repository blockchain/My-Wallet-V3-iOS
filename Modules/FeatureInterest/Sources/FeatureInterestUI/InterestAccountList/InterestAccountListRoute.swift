// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import SwiftUI
import ToolKit

enum InterestAccountListRoute: NavigationRoute, CaseIterable {

    case details
    case transaction
    case noWalletsError

    @ViewBuilder
    func destination(in store: Store<InterestAccountListState, InterestAccountListAction>) -> some View {
        switch self {
        case .details:
            IfLetStore(
                store.scope(
                    state: \.interestAccountDetailsState,
                    action: InterestAccountListAction.interestAccountDetails
                ),
                then: InterestAccountDetailsView.init(store:)
            )
        case .transaction:
            WithViewStore(store, observe: { $0 }) { viewStore in
                InterestTransactionHostingView(state: viewStore.interestTransactionState!)
            }
        case .noWalletsError:
            IfLetStore(
                store.scope(
                    state: \.interestNoEligibleWalletsState,
                    action: InterestAccountListAction.interestAccountNoEligibleWallets
                ),
                then: InterestNoEligibleWalletsView.init(store:)
            )
        }
    }
}
