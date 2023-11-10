// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MetadataKit

struct StellarWallet: Equatable {
    let accounts: [StellarWalletAccount]

    var defaultAccountIndex: Int {
        entry?.defaultAccountIndex ?? 0
    }

    let entry: StellarEntryPayload?

    init(entry: StellarEntryPayload?, accounts: [StellarWalletAccount]) {
        self.entry = entry
        self.accounts = accounts
    }
}

struct StellarWalletAccount: Equatable {
    let index: Int
    let publicKey: String
    let label: String?
    let archived: Bool

    init(index: Int, publicKey: String, label: String? = nil, archived: Bool = false) {
        self.index = index
        self.publicKey = publicKey
        self.label = label
        self.archived = archived
    }
}
