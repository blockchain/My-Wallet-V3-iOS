// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

/// A BlockchainAccount that represents a single account, opposed to a collection of accounts.
public protocol SingleAccount: BlockchainAccount, TransactionTarget {
    var isDefault: Bool { get }
}
