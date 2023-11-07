// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum TransactionCost {
    enum Base {
        static let p2pkh: Decimal = 10
        static let p2wpkh: Decimal = 10.75
    }

    enum PerInput {
        static let p2pkh: Decimal = 148
        static let p2sh: Decimal = 297
        static let p2wpkh: Decimal = 67.75
        static let p2wsh: Decimal = 104.5

        static func `for`(_ type: BitcoinScriptType) -> Decimal {
            switch type {
            case .P2PKH:
                p2pkh
            case .P2SH:
                p2sh
            case .P2WPKH:
                p2wpkh
            case .P2WSH:
                p2wsh
            }
        }
    }

    enum PerOutput {
        static let p2pkh: Decimal = 34
        static let p2sh: Decimal = 32
        static let p2wpkh: Decimal = 31
        static let p2wsh: Decimal = 43

        static func `for`(_ type: BitcoinScriptType) -> Decimal {
            switch type {
            case .P2PKH:
                p2pkh
            case .P2SH:
                p2sh
            case .P2WPKH:
                p2wpkh
            case .P2WSH:
                p2wsh
            }
        }
    }
}
