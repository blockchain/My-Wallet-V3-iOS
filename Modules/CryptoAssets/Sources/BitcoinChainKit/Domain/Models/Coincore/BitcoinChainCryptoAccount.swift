// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

public protocol BitcoinChainCryptoAccount: CryptoNonCustodialAccount {

    var coinType: BitcoinChainCoin { get }

    var hdAccountIndex: Int { get }

    var xPub: XPub { get }

    /// Returns `true` if this acocunt is an imported address, otherwise `false`
    var isImported: Bool { get }

    /// Available only on imported addresses
    var importedPrivateKey: String? { get }
}
