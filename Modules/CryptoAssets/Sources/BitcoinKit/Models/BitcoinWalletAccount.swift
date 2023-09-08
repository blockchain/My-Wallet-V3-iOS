// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import ToolKit

struct BitcoinWalletAccount: Equatable {

    // MARK: Properties

    let archived: Bool
    let index: Int
    let label: String
    let publicKeys: Either<XPubs, XPub>

    var defaultXPub: XPub {
        publicKeys.fold(
            left: { $0.default },
            right: { $0 }
        )
    }

    var xpubs: [XPub] {
        publicKeys.fold(
            left: { $0.xpubs },
            right: { [$0] }
        )
    }

    let importedPrivateKey: String?
    let imported: Bool

    // MARK: Internal Properties

    var isActive: Bool {
        !archived
    }

    // MARK: Initializers

    init(index: Int, label: String, archived: Bool, publicKeys: Either<XPubs, XPub>, importedPrivateKey: String? = nil, imported: Bool = false) {
        self.index = index
        self.label = label
        self.archived = archived
        self.importedPrivateKey = importedPrivateKey
        self.imported = imported
        self.publicKeys = publicKeys
    }

    func updateLabel(_ value: String) -> BitcoinWalletAccount {
        .init(index: index, label: value, archived: archived, publicKeys: publicKeys, importedPrivateKey: importedPrivateKey, imported: imported)
    }
}
