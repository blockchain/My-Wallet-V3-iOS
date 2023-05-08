// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Foundation

public struct SwapSelectAccountRow: ReducerProtocol {
    public let app: AppProtocol
    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case onAccountTapped
        case binding(BindingAction<SwapSelectAccountRow.State>)
    }

    public struct State: Equatable, Identifiable {
        public var id: String {
            accountId
        }

        var accountId: String
        var isLastRow: Bool
        var appMode: AppMode?
        var currency: CryptoCurrency
        @BindingState var label: String?
        @BindingState var networkLogo: URL?
        @BindingState var networkName: String?

        var leadingDescription: String {
            currency.name
        }

        public init(
            isLastRow: Bool,
            accountId: String,
            currency: CryptoCurrency
        ) {
            self.isLastRow = isLastRow
            self.accountId = accountId
            self.currency = currency
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { _, action in
            switch action {
            case .binding:
                return .none
            case .onAccountTapped:
                return .none
            }
        }
    }
}
