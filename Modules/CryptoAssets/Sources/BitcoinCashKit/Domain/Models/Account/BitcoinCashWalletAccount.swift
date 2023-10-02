// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import PlatformKit

public struct BitcoinCashWalletAccount: Equatable {

    public let archived: Bool
    public let index: Int
    public let label: String?
    public let publicKey: XPub

    public let importedPrivateKey: String?
    public let imported: Bool

    public init(
        index: Int,
        publicKey: String,
        label: String?,
        derivationType: DerivationType,
        archived: Bool,
        importedPrivateKey: String? = nil,
        imported: Bool = false
    ) {
        self.archived = archived
        self.index = index
        self.label = label
        self.publicKey = XPub(address: publicKey, derivationType: derivationType)
        self.importedPrivateKey = importedPrivateKey
        self.imported = imported
    }
}
