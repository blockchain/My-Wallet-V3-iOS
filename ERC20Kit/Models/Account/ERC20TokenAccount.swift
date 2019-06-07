//
//  ERC20TokenAccount.swift
//  ERC20Kit
//
//  Created by Jack on 31/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO:
// * This should probably conform to either WalletAccount or AssetAccount
public struct ERC20TokenAccount: Codable {
    
    enum CodingKeys: String, CodingKey {
        case label
        case contractAddress = "contract"
        case hasSeen = "has_seen"
        case transactionNotes = "tx_notes"
    }
    
    public let label: String
    public let contractAddress: String
    public let hasSeen: Bool
    public private(set) var transactionNotes: [String: String]
    
    public init(
        label: String,
        contractAddress: String,
        hasSeen: Bool,
        transactionNotes: [String: String]) {
        self.label = label
        self.contractAddress = contractAddress
        self.hasSeen = hasSeen
        self.transactionNotes = transactionNotes
    }
    
    public mutating func update(memo: String, for transactionHash: String) {
        transactionNotes[transactionHash] = memo
    }
}
