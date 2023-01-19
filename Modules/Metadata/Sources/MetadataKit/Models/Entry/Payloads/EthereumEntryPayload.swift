// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct EthereumEntryPayload: MetadataNodeEntry, Hashable {

    public struct Ethereum: Codable, Hashable {

        public struct Account: Codable, Hashable {

            public enum CodingKeys: String, CodingKey {
                case address = "addr"
                case archived
                case correct
                case label
            }

            public let address: String
            public let archived: Bool
            public let correct: Bool
            public let label: String

            public init(
                address: String,
                archived: Bool,
                correct: Bool,
                label: String
            ) {
                self.address = address
                self.archived = archived
                self.correct = correct
                self.label = label
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.address = try container.decode(String.self, forKey: .address)
                self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
                self.correct = try container.decodeIfPresent(Bool.self, forKey: .correct) ?? true
                self.label = try container.decode(String.self, forKey: .label)
            }

            public func updateLabel(_ value: String) -> Account {
                .init(address: address, archived: archived, correct: correct, label: value)
            }
        }

        public struct ERC20: Codable, Hashable {

            public enum CodingKeys: String, CodingKey {
                case contract
                case hasSeen = "has_seen"
                case label
                case txNotes = "tx_notes"
            }

            public let contract: String
            public let hasSeen: Bool
            public let label: String
            public let txNotes: [String: String]

            public init(
                contract: String,
                hasSeen: Bool,
                label: String,
                txNotes: [String: String]
            ) {
                self.contract = contract
                self.hasSeen = hasSeen
                self.label = label
                self.txNotes = txNotes
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.contract = try container.decode(String.self, forKey: .contract)
                self.hasSeen = try container.decodeIfPresent(Bool.self, forKey: .hasSeen) ?? false
                self.label = try container.decode(String.self, forKey: .label)
                self.txNotes = try container.decodeIfPresent([String: String].self, forKey: .txNotes) ?? [:]
            }
        }

        public enum CodingKeys: String, CodingKey {
            case accounts
            case defaultAccountIndex = "default_account_idx"
            case erc20
            case hasSeen = "has_seen"
            case lastTxTimestamp = "last_tx_timestamp"
            case transactionNotes = "tx_notes"
        }

        public let accounts: [Account]
        public let defaultAccountIndex: Int
        public let erc20: [String: ERC20]?
        public let hasSeen: Bool
        public let lastTxTimestamp: Int?
        public let transactionNotes: [String: String]

        public init(
            accounts: [Account],
            defaultAccountIndex: Int,
            erc20: [String: ERC20]?,
            hasSeen: Bool,
            lastTxTimestamp: Int?,
            transactionNotes: [String: String]
        ) {
            self.accounts = accounts
            self.defaultAccountIndex = defaultAccountIndex
            self.erc20 = erc20
            self.hasSeen = hasSeen
            self.lastTxTimestamp = lastTxTimestamp
            self.transactionNotes = transactionNotes
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.accounts = try container.decode([Account].self, forKey: .accounts)
            self.defaultAccountIndex = try container.decodeIfPresent(Int.self, forKey: .defaultAccountIndex) ?? 0
            self.erc20 = try container.decodeIfPresent([String: ERC20].self, forKey: .erc20) ?? [:]
            self.hasSeen = try container.decode(Bool.self, forKey: .hasSeen)
            self.lastTxTimestamp = try container.decodeIfPresent(Int.self, forKey: .lastTxTimestamp)
            self.transactionNotes = try container.decodeIfPresent([String: String].self, forKey: .transactionNotes) ?? [:]
        }
    }

    public enum CodingKeys: String, CodingKey {
        case ethereum
    }

    public static let type: EntryType = .ethereum

    public let ethereum: Ethereum?

    public init(ethereum: Ethereum) {
        self.ethereum = ethereum
    }
}

// MARK: - Internal, should only be used in testing -

extension EthereumEntryPayload {
    init(ethereum: Ethereum?) {
        self.ethereum = ethereum
    }
}
