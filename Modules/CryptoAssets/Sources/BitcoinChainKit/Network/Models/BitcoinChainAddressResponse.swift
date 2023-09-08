// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct BitcoinChainAddressResponse: Decodable, Equatable {
    public let accountIndex: Int?
    public let address: String
    public let changeIndex: Int?
    public let finalBalance: Int
    public let nTx: Int
    public let totalReceived: Int
    public let totalSent: Int

    private enum CodingKeys: String, CodingKey {
        case accountIndex = "account_index"
        case address
        case changeIndex = "change_index"
        case finalBalance = "final_balance"
        case nTx = "n_tx"
        case totalReceived = "total_received"
        case totalSent = "total_sent"
    }
}
