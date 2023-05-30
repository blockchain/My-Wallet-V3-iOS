// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Foundation

public struct SwapSelectAccount: ReducerProtocol {
    public let app: AppProtocol

    public init(app: AppProtocol) {
        self.app = app
    }

    public struct State: Equatable {
        public init(
            accountIds: [String],
            currency: CryptoCurrency
        ) {
            let accountRows = accountIds
                .map {
                    SwapSelectAccountRow.State(
                        isLastRow: $0 == accountIds.last,
                        accountId: $0,
                        currency: currency
                    )
                }
            self.accountRows = IdentifiedArrayOf(uniqueElements: accountRows)
            self.currency = currency
        }

        var accountRows: IdentifiedArrayOf<SwapSelectAccountRow.State> = []
        var currency: CryptoCurrency
    }

    public enum Action: Equatable {
        case accountRow(
            id: SwapSelectAccountRow.State.ID,
            action: SwapSelectAccountRow.Action
        )
        case onAccountSelected(String)
        case onCloseTapped
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            default:
                return .none
            }
        }
        .forEach(\.accountRows, action: /Action.accountRow(id:action:)) {
            SwapSelectAccountRow(app: app)
        }
    }
}
