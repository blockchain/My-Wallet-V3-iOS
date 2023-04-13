// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeatureOpenBankingDomain

public struct Capabilities: Decodable, Equatable, Hashable {
    public struct Capability: Decodable, Equatable, Hashable {
        public let enabled: Bool, ux: UX.Dialog?
    }

    public let deposit, withdrawal: Capability?
}

public struct LinkedBankResponse: Decodable {
    enum AccountType: String, Decodable {
        case savings = "SAVINGS"
        case checking = "CHECKING"
        case none = "UNKNOWN"
    }

    let id: String
    let currency: String
    let partner: String
    let bankAccountType: AccountType
    let name: String
    let accountName: String?
    let accountNumber: String?
    let routingNumber: String?
    let agentRef: String?
    let isBankAccount: Bool
    let isBankTransferAccount: Bool
    let state: State
    let attributes: Attributes?
    let error: Error?
    let errorCode: String?
    let capabilities: Capabilities?

    enum CodingKeys: CodingKey {
        case id
        case currency
        case partner
        case state
        case details
        case error
        case isBankAccount
        case isBankTransferAccount
        case attributes
        case bankAccountType
        case name
        case accountName
        case accountNumber
        case routingNumber
        case agentRef
        case capabilities
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.partner = try container.decode(String.self, forKey: .partner)
        self.state = try container.decode(State.self, forKey: .state)
        /// The `updateBankLinkage` call in `APIClient` does not return a model that
        /// matches `LinkedBankResponse`. We can set the below properties to a default value
        /// as the caller of `updateBankLinkage` does not use any part of the `LinkedBankResponse`
        /// object except for `state`.
        self.isBankAccount = try (container.decodeIfPresent(Bool.self, forKey: .isBankAccount) ?? false)
        self.isBankTransferAccount = try (container.decodeIfPresent(Bool.self, forKey: .isBankTransferAccount) ?? false)
        self.name = try (container.decodeIfPresent(String.self, forKey: .name) ?? "")
        self.attributes = try container.decodeIfPresent(Attributes.self, forKey: .attributes)
        self.error = try? container.decodeIfPresent(Error.self, forKey: .error)
        self.errorCode = try container.decodeIfPresent(String.self, forKey: .error)
        let accountType = try container.decodeIfPresent(AccountType.self, forKey: .bankAccountType)
        self.bankAccountType = accountType ?? .none
        self.accountName = try container.decodeIfPresent(String.self, forKey: .accountName)
        self.accountNumber = try container.decodeIfPresent(String.self, forKey: .accountNumber)
        self.routingNumber = try container.decodeIfPresent(String.self, forKey: .routingNumber)
        self.agentRef = try container.decodeIfPresent(String.self, forKey: .agentRef)
        self.capabilities = try? container.decodeIfPresent(Capabilities.self, forKey: .capabilities)
    }
}

extension LinkedBankResponse {
    struct Attributes: Decodable {
        let entity: String?
        let media: [Media]?
        let status: String?
        let authorisationUrl: URL?

        struct Media: Decodable {
            let source: String
            let type: String
        }
    }
}

extension LinkedBankResponse {
    public enum State: String, Codable {
        case pending = "PENDING"
        case active = "ACTIVE"
        case blocked = "BLOCKED"
    }

    public enum Error: String, Codable {
        case alreadyLinked = "BANK_TRANSFER_ACCOUNT_ALREADY_LINKED"
        case infoNotFound = "BANK_TRANSFER_ACCOUNT_INFO_NOT_FOUND"
        case nameMismatch = "BANK_TRANSFER_ACCOUNT_NAME_MISMATCH"
        case expired = "BANK_TRANSFER_ACCOUNT_EXPIRED"
        case rejected = "BANK_TRANSFER_ACCOUNT_REJECTED"
        case failed = "BANK_TRANSFER_ACCOUNT_FAILED"
        case invalid = "BANK_TRANSFER_ACCOUNT_INVALID"
        case notSupported = "BANK_TRANSFER_ACCOUNT_NOT_SUPPORTED"
        case failedInternal = "BANK_TRANSFER_ACCOUNT_FAILED_INTERNAL"
        case rejectedFraud = "BANK_TRANSFER_ACCOUNT_REJECTED_FRAUD"
        case unknown = ""
    }
}

enum BankLinkagePartner: String, Decodable {
    case yodlee = "YODLEE"
    case yapily = "YAPILY"
}

struct CreateBankLinkageResponse: Decodable {
    struct LinkBankAttrsResponse: Decodable {
        let entity: String?
        let token: String?
        let fastlinkUrl: String?
        let fastlinkParams: FastlinkParameters?
        let institutions: [OpenBanking.Institution]?
    }

    let id: String
    let partner: BankLinkagePartner
    let attributes: LinkBankAttrsResponse?
}

/// The specific configuration for when requesting the webview of the partner (Yodlee/Yapily)
struct FastlinkParameters: Decodable {
    let configName: String
}
