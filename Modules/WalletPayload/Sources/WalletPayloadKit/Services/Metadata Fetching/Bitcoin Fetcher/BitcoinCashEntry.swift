// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization
import MetadataKit

/// An entry model that contains information on constructing BitcoinCash wallet account
public struct BitcoinCashEntry: Equatable {
    public struct AccountEntry: Equatable {
        public let index: Int
        public let publicKey: String
        public let label: String?
        public let derivationType: DerivationType
        public let archived: Bool

        public func updateLabel(_ value: String) -> AccountEntry {
            .init(index: index, publicKey: publicKey, label: value, derivationType: derivationType, archived: archived)
        }
    }

    public let payload: BitcoinCashEntryPayload
    public let accounts: [AccountEntry]
    public let txNotes: [String: String]?

    public var defaultAccount: AccountEntry {
        precondition(payload.defaultAccountIndex < accounts.count)
        return accounts[payload.defaultAccountIndex]
    }

    public init(
        payload: BitcoinCashEntryPayload,
        accounts: [AccountEntry],
        txNotes: [String: String]?
    ) {
        self.payload = payload
        self.accounts = accounts
        self.txNotes = txNotes
    }

    init(
        payload: BitcoinCashEntryPayload,
        wallet: NativeWallet
    ) {
        self.payload = payload
        self.txNotes = payload.txNotes
        let accountsData = payload.accounts
        let hdWalletAccounts = wallet.defaultHDWallet?.accounts ?? []
        self.accounts = hdWalletAccounts
            .enumerated()
            .map { index, btcAccount -> AccountEntry in
                let accountData = index < accountsData.count ? accountsData[index] : nil
                let extendedPublicKey = btcAccount.defaultDerivationAccount?.xpub ?? ""
                let publicKey = btcAccount.derivation(for: .legacy)?.xpub
                return AccountEntry(
                    index: btcAccount.index,
                    publicKey: publicKey ?? extendedPublicKey,
                    label: accountData?.label,
                    derivationType: .legacy,
                    archived: accountData?.archived ?? false
                )
            }
    }

    func toMetadataEntry() -> BitcoinCashEntryPayload {
        BitcoinCashEntryPayload(
            accounts: accounts.map { $0.toMetadataEntry() },
            defaultAccountIndex: payload.defaultAccountIndex,
            hasSeen: payload.hasSeen,
            txNotes: txNotes,
            addresses: payload.addresses
        )
    }
}

extension BitcoinCashEntry.AccountEntry {
    func toMetadataEntry() -> BitcoinCashEntryPayload.Account {
        BitcoinCashEntryPayload.Account(
            archived: archived,
            label: label ?? LocalizationConstants.Account.myWallet
        )
    }
}
