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

public struct WalletConnectAuthRequest: Equatable, Codable, Hashable {
    public struct AccountInfo: Equatable, Codable, Hashable {
        public let label: String
        public let identifier: String
        public let address: String
        public let network: EVMNetwork
    }
    public let request: AuthRequest
    public let accountInfo: AccountInfo

    public let formattedMessage: String

    public var domain: String {
        request.payload.domain
    }

    public init(
        request: AuthRequest,
        accountInfo: AccountInfo,
        formattedMessage: String
    ) {
        self.request = request
        self.accountInfo = accountInfo
        self.formattedMessage = formattedMessage
    }
}
