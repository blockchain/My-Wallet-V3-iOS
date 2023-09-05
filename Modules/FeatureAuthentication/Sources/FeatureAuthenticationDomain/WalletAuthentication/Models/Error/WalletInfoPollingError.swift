// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions

public enum WalletInfoPollingError: Error, Equatable {
    case continuePolling
    case requestDenied
}
