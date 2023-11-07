// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit

public enum FeeLevel: Equatable {
    case none
    case regular
    case priority
    case custom

    public var isFeeLess: Bool {
        self == .none
    }

    public var title: String {
        switch self {
        case .none:
            ""
        case .regular:
            LocalizationConstants.Transaction.Send.regular
        case .priority:
            LocalizationConstants.Transaction.Send.priority
        case .custom:
            LocalizationConstants.Transaction.Send.custom
        }
    }
}

extension Collection<FeeLevel> {
    /// If there's more than one `FeeLevel` (excluding `.none`)
    /// than the transaction supports adjusting the `FeeLevel`
    public var networkFeeAdjustmentSupported: Bool {
        filter { $0 != .none }.count > 1
    }
}
