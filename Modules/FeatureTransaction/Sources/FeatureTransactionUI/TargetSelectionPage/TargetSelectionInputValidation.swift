// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

enum TargetSelectionInputValidation: Equatable {

    case empty
    case account(Account)
    case text(TextInput, MemoInput, ReceiveAddress?)
    case QR(QRInput)

    var textInput: TextInput? {
        switch self {
        case .text(let value, _, _):
            return value
        case .empty,
             .QR,
             .account:
            return nil
        }
    }

    var isAccountSelection: Bool {
        switch self {
        case .account:
            return true
        case .empty,
             .QR,
             .text:
            return false
        }
    }

    var isValid: Bool {
        switch self {
        case .QR(let input):
            return input.isValid
        case .account(let account):
            return account.isValid
        case .text(let input, _, _):
            return input.isValid
        case .empty:
            return false
        }
    }

    var text: String {
        switch self {
        case .text(let input, _, _):
            return input.text
        case .QR(let qrInput):
            return qrInput.text
        case .account,
             .empty:
            return ""
        }
    }

    var memoText: String {
        switch self {
        case .text(_, let memo, _):
            return memo.text
        case .QR(let qrInput):
            return qrInput.memoText
        case .account, .empty:
            return ""
        }
    }

    enum Account: Equatable {
        case none
        case account(BlockchainAccount)

        var isValid: Bool {
            switch self {
            case .account:
                return true
            case .none:
                return false
            }
        }
    }

    enum MemoInput: Equatable {
        case inactive
        case invalid(String)
        case valid(String)

        var text: String {
            switch self {
            case .inactive:
                return ""
            case .invalid(let value), .valid(let value):
                return value
            }
        }

        var isValid: Bool {
            switch self {
            case .inactive, .valid:
                return true
            case .invalid:
                return false
            }
        }
    }

    enum TextInput: Equatable {
        case inactive
        case invalid(String)
        case valid(String)

        var text: String {
            switch self {
            case .inactive:
                return ""
            case .invalid(let value):
                return value
            case .valid(let input):
                return input
            }
        }

        var isValid: Bool {
            switch self {
            case .valid:
                return true
            default:
                return false
            }
        }
    }

    /// When the user scans from the QR scanner the input can be
    /// an address with an optional amount or memo.
    enum QRInput: Equatable {
        /// The user has not scanned anything
        case empty
        case valid(CryptoReceiveAddress)

        var text: String {
            switch self {
            case .empty:
                return ""
            case .valid(let value):
                return value.address
            }
        }

        var memoText: String {
            switch self {
            case .empty:
                return ""
            case .valid(let value):
                return value.memo ?? ""
            }
        }

        var isValid: Bool {
            switch self {
            case .valid:
                return true
            case .empty:
                return false
            }
        }
    }
}

extension TargetSelectionInputValidation {
    static func == (lhs: TargetSelectionInputValidation, rhs: TargetSelectionInputValidation) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.account(let lhs), .account(let rhs)):
            return lhs == rhs
        case (.QR(let lhs), .QR(let rhs)):
            return lhs == rhs
        case (.text(let lhsInput, let lhsMemo, let lhsAddress), .text(let rhsInput, let rhsMemo, let rhsAddress)):
            return lhsInput == rhsInput
                && lhsMemo == rhsMemo
                && lhsAddress?.address == rhsAddress?.address
                && lhsAddress?.memo == rhsAddress?.memo
        default:
            return false
        }
    }
}

extension TargetSelectionInputValidation.QRInput {
    static func == (lhs: TargetSelectionInputValidation.QRInput, rhs: TargetSelectionInputValidation.QRInput) -> Bool {
        switch (lhs, rhs) {
        case (.valid(let leftAddress), .valid(let rightAddress)):
            return leftAddress.address == rightAddress.address
                && leftAddress.memo == rightAddress.memo
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

extension TargetSelectionInputValidation.Account {
    static func == (lhs: TargetSelectionInputValidation.Account, rhs: TargetSelectionInputValidation.Account) -> Bool {
        switch (lhs, rhs) {
        case (.account(let left), .account(let right)):
            return left.label == right.label
                && left.identifier == right.identifier
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}
