// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Errors
import MoneyKit

public struct PendingTransaction: ReducerProtocol {

    public struct State: Hashable {
        var currency: CryptoCurrency
        var status: ViewState
    }

    enum ViewState: Hashable {
        case error(UX.Error)
        case inProgress(DexDialog)
        case success(DexDialog, CryptoCurrency)
    }

    public enum Action: Hashable {}

    let app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
