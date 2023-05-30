// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Errors
import MoneyKit

public enum PendingTransaction {

    public struct State: Hashable {
        var currency: CryptoCurrency
        var status: ViewState
    }

    enum ViewState: Hashable {
        case error(UX.Error)
        case inProgress(DexDialog)
        case success(DexDialog, CryptoCurrency)
    }
}
