// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions
import ToolKit

public struct SwapFromAccountSelect: ReducerProtocol {
    private var app: AppProtocol

    public enum SelectionType {
        case source
        case target
    }

    public struct State: Equatable {
        var isLoading: Bool = false
        var appMode: AppMode?
        var availableAccounts: [String] = []
        var swapAccountRows: IdentifiedArrayOf<SwapFromAccountRow.State> = []
    }

    public enum Action {
        case accountRow(
            id: SwapFromAccountRow.State.ID,
            action: SwapFromAccountRow.Action
        )
        case onAppear
        case onAvailableAccountsFetched([String])
        case onCloseTapped
    }

    public init(app: AppProtocol) {
        self.app = app
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .accountRow:
                return .none

            case .onAppear:
                state.appMode = app.currentMode
                state.isLoading = true
                return .run { [
                    appMode = state.appMode
                ] send in
                    do {
                        if appMode == .pkw {
                            let availableAccounts = try await app.get(blockchain.coin.core.accounts.DeFi.with.balance, as: [String].self)
                            await send(.onAvailableAccountsFetched(availableAccounts))
                        } else {
                            let availableAccounts = try await app.get(blockchain.coin.core.accounts.custodial.crypto.with.balance, as: [String].self)
                            await send(.onAvailableAccountsFetched(availableAccounts))
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }

            case .onAvailableAccountsFetched(let accounts):
                state.isLoading = false
                let elements = accounts
                    .map {
                        SwapFromAccountRow.State(
                            isLastRow: $0 == accounts.last,
                            assetCode: $0
                        )
                    }
                state.swapAccountRows = IdentifiedArrayOf(uniqueElements: elements)
                return .none

            case .onCloseTapped:
                return .none
            }
        }
        .forEach(\.swapAccountRows, action: /Action.accountRow(id:action:)) {
            SwapFromAccountRow(app: app)
        }
    }
}
