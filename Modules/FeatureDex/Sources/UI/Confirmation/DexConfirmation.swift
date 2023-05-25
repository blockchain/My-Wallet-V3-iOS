// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import SwiftUI

public struct DexConfirmation: ReducerProtocol {

    @Dependency(\.dexService) var dexService

    let app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .acceptPrice:
                state.priceUpdated = false
                return .none
            case .confirm:
                state.didConfirm = true
                return .none
            }
        }
    }
}
