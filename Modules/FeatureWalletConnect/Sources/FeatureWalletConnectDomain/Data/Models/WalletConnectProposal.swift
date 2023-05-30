// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import Web3Wallet

public struct WalletConnectProposal: Equatable, Codable, Hashable {
    public let proposal: SessionV2.Proposal
    public let account: String
    public let networks: [EVMNetwork]
}

public enum WalletConnectProposalResult: Equatable, Codable, Hashable {
    case request(WalletConnectProposal)
    case failure(message: String?, metadata: AppMetadata)
}
