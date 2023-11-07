// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

public enum AccountPickerRow: Equatable, Identifiable {
    case label(Label)
    case button(Button)
    case linkedBankAccount(LinkedBankAccount)
    case paymentMethodAccount(PaymentMethod)
    case accountGroup(AccountGroup)
    case singleAccount(SingleAccount)
    case withdrawalLocks

    public var id: AnyHashable {
        switch self {
        case .label(let model):
            model.id
        case .button(let model):
            model.id
        case .linkedBankAccount(let model):
            model.id
        case .paymentMethodAccount(let model):
            model.id
        case .accountGroup(let model):
            model.id
        case .singleAccount(let model):
            model.id
        case .withdrawalLocks:
            "withdrawal-locks-id"
        }
    }

    public var currency: String? {
        switch self {
        case .singleAccount(let model):
            model.currency
        default:
            nil
        }
    }

    var isAccountGroup: Bool {
        switch self {
        case .accountGroup:
            true
        default:
            false
        }
    }

    var isSingleAccount: Bool {
        switch self {
        case .singleAccount:
            true
        default:
            false
        }
    }
}
