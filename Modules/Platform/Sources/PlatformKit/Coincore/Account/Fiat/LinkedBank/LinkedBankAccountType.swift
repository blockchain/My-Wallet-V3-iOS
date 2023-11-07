// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum LinkedBankAccountType {
    case savings
    case checking
    case unknown
}

extension LinkedBankAccountType {
    public var title: String {
        switch self {
        case .checking:
            LocalizationConstants.Transaction.checking
        case .savings:
            LocalizationConstants.Transaction.savings
        case .unknown:
            ""
        }
    }
}

extension LinkedBankAccountType {
    init(from type: LinkedBankResponse.AccountType) {
        switch type {
        case .none:
            self = .unknown
        case .savings:
            self = .savings
        case .checking:
            self = .checking
        }
    }
}
