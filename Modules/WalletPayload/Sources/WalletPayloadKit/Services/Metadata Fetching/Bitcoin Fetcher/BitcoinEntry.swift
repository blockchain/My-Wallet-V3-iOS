// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

/// An entry model that contains information on constructing Bitcoin wallet account
public struct BitcoinEntry: Equatable {
    public struct XPub: Equatable {
        public let address: String
        public let type: DerivationType
    }

    public struct Account: Equatable {
        public let index: Int
        public let label: String
        public let archived: Bool
        public let xpubs: [XPub]
    }

    public struct ImportedAddress: Equatable {
        public let addr: String
        public let priv: String?
        public let archived: Bool
        public let label: String?
    }

    private let payload: BitcoinEntryPayload

    public let defaultAccountIndex: Int

    public let accounts: [BitcoinEntry.Account]
    public let importedAddresses: [BitcoinEntry.ImportedAddress]

    init(payload: BitcoinEntryPayload, wallet: NativeWallet) {
        self.payload = payload
        self.defaultAccountIndex = wallet.defaultHDWallet?.defaultAccountIndex ?? 0
        let hdWalletAccounts = wallet.defaultHDWallet?.accounts ?? []

        self.accounts = hdWalletAccounts
            .enumerated()
            .map { index, account in
                let xpubs = account.derivations.compactMap { derivation -> XPub? in
                    guard let xpub = derivation.xpub,
                          let type = derivation.type
                    else {
                        return nil
                    }
                    return XPub(address: xpub, type: type)
                }
                return Account(
                    index: index,
                    label: account.label,
                    archived: account.archived,
                    xpubs: xpubs
                )
            }

        self.importedAddresses = wallet.addresses.map { address in
            BitcoinEntry.ImportedAddress(
                addr: address.addr,
                priv: address.priv,
                archived: address.isArchived,
                label: address.label
            )
        }
    }
}
