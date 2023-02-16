// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct StellarEntryPayload: MetadataNodeEntry, Hashable {

    public enum CodingKeys: String, CodingKey {
        case accounts
        case defaultAccountIndex = "default_account_idx"
        case txNotes = "tx_notes"
    }

    public struct Account: Codable, Hashable {

        public enum CodingKeys: String, CodingKey {
            case archived
            case label
            case publicKey
        }

        public let archived: Bool
        public let label: String
        public let publicKey: String

        public init(
            archived: Bool,
            label: String,
            publicKey: String
        ) {
            self.archived = archived
            self.label = label
            self.publicKey = publicKey
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
            self.label = try container.decode(String.self, forKey: .label)
            self.publicKey = try container.decode(String.self, forKey: .publicKey)
        }

        public func updateLabel(_ value: String) -> Account {
            .init(archived: archived, label: value, publicKey: publicKey)
        }
    }

    public static let type: EntryType = .stellar

    public let accounts: [Account]
    public let defaultAccountIndex: Int
    public let txNotes: [String: String]?

    public init(
        accounts: [Account],
        defaultAccountIndex: Int,
        txNotes: [String: String]?
    ) {
        self.accounts = accounts
        self.defaultAccountIndex = defaultAccountIndex
        self.txNotes = txNotes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accounts = try container.decode([Account].self, forKey: .accounts)
        self.defaultAccountIndex = try container.decodeIfPresent(Int.self, forKey: .defaultAccountIndex) ?? 0
        self.txNotes = try container.decodeIfPresent([String: String].self, forKey: .txNotes)
    }
}
