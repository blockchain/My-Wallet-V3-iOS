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
            value
        case .empty,
             .QR,
             .account:
            nil
        }
    }

    var isAccountSelection: Bool {
        switch self {
        case .account:
            true
        case .empty,
             .QR,
             .text:
            false
        }
    }

    var isValid: Bool {
        switch self {
        case .QR(let input):
            input.isValid
        case .account(let account):
            account.isValid
        case .text(let input, _, _):
            input.isValid
        case .empty:
            false
        }
    }

    var text: String {
        switch self {
        case .text(let input, _, _):
            input.text
        case .QR(let qrInput):
            qrInput.text
        case .account,
             .empty:
            ""
        }
    }

    var memoText: String {
        switch self {
        case .text(_, let memo, _):
            memo.text
        case .QR(let qrInput):
            qrInput.memoText
        case .account, .empty:
            ""
        }
    }

    enum Account: Equatable {
        case none
        case account(BlockchainAccount)

        var isValid: Bool {
            switch self {
            case .account:
                true
            case .none:
                false
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
                ""
            case .invalid(let value), .valid(let value):
                value
            }
        }

        var isValid: Bool {
            switch self {
            case .inactive, .valid:
                true
            case .invalid:
                false
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
                ""
            case .invalid(let value):
                value
            case .valid(let input):
                input
            }
        }

        var isValid: Bool {
            switch self {
            case .valid:
                true
            default:
                false
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
                ""
            case .valid(let value):
                value.address
            }
        }

        var memoText: String {
            switch self {
            case .empty:
                ""
            case .valid(let value):
                value.memo ?? ""
            }
        }

        var isValid: Bool {
            switch self {
            case .valid:
                true
            case .empty:
                false
            }
        }
    }
}

extension TargetSelectionInputValidation {
    static func == (lhs: TargetSelectionInputValidation, rhs: TargetSelectionInputValidation) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            true
        case (.account(let lhs), .account(let rhs)):
            lhs == rhs
        case (.QR(let lhs), .QR(let rhs)):
            lhs == rhs
        case (.text(let lhsInput, let lhsMemo, let lhsAddress), .text(let rhsInput, let rhsMemo, let rhsAddress)):
            lhsInput == rhsInput
                && lhsMemo == rhsMemo
                && lhsAddress?.address == rhsAddress?.address
                && lhsAddress?.memo == rhsAddress?.memo
        default:
            false
        }
    }
}

extension TargetSelectionInputValidation.QRInput {
    static func == (lhs: TargetSelectionInputValidation.QRInput, rhs: TargetSelectionInputValidation.QRInput) -> Bool {
        switch (lhs, rhs) {
        case (.valid(let leftAddress), .valid(let rightAddress)):
            leftAddress.address == rightAddress.address
                && leftAddress.memo == rightAddress.memo
        case (.empty, .empty):
            true
        default:
            false
        }
    }
}

extension TargetSelectionInputValidation.Account {
    static func == (lhs: TargetSelectionInputValidation.Account, rhs: TargetSelectionInputValidation.Account) -> Bool {
        switch (lhs, rhs) {
        case (.account(let left), .account(let right)):
            left.label == right.label
                && left.identifier == right.identifier
        case (.none, .none):
            true
        default:
            false
        }
    }
}
