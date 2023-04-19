// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnyCoding
import DIKit
import MoneyKit
import ToolKit

public struct NabuUser: Decodable, Equatable {

    // MARK: - Types

    public enum UserState: String, Codable {
        case none = "NONE"
        case created = "CREATED"
        case active = "ACTIVE"
        case blocked = "BLOCKED"
    }

    /// Products used by the user
    public struct ProductsUsed: Decodable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case exchange
        }

        let exchange: Bool

        public init(exchange: Bool) {
            self.exchange = exchange
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.exchange = try values.decodeIfPresent(Bool.self, forKey: .exchange) ?? false
        }
    }

    // MARK: - Properties

    public let identifier: String
    public let personalDetails: PersonalDetails
    public let address: UserAddress?
    public let email: Email
    public let mobile: Mobile?
    public let status: KYC.AccountStatus
    public let state: UserState
    public let tiers: KYC.UserState?
    public let currencies: Currencies
    let tags: Tags?
    public let needsDocumentResubmission: DocumentResubmission?
    public let userName: String?
    public let depositAddresses: [DepositAddress]
    private let productsUsed: ProductsUsed?
    private let settings: NabuUserSettings?

    /// ISO-8601 Timestamp w/millis, eg 2018-08-15T17:00:45.129Z
    public let kycCreationDate: String?

    /// ISO-8601 Timestamp w/millis, eg 2018-08-15T17:00:45.129Z
    public let kycUpdateDate: String?

    public let unifiedAccountWalletGuid: String?

    public var isSSO: Bool {
        unifiedAccountWalletGuid != nil
    }

    // MARK: - Decodable

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case address
        case status = "kycState"
        case state
        case tags
        case tiers
        case needsDocumentResubmission = "resubmission"
        case userName
        case settings
        case productsUsed
        case kycCreationDate = "insertedAt"
        case kycUpdateDate = "updatedAt"
        case depositAddresses = "walletAddresses"
        case currencies
        case unifiedAccountWalletGuid
    }

    // MARK: - Init

    init(
        identifier: String,
        personalDetails: PersonalDetails,
        address: UserAddress?,
        email: Email,
        mobile: Mobile?,
        status: KYC.AccountStatus,
        state: UserState,
        currencies: Currencies,
        tags: Tags?,
        tiers: KYC.UserState?,
        needsDocumentResubmission: DocumentResubmission?,
        userName: String? = nil,
        depositAddresses: [DepositAddress] = [],
        productsUsed: ProductsUsed,
        settings: NabuUserSettings,
        kycCreationDate: String? = nil,
        kycUpdateDate: String? = nil,
        unifiedAccountWalletGuid: String? = nil
    ) {
        self.identifier = identifier
        self.personalDetails = personalDetails
        self.address = address
        self.email = email
        self.mobile = mobile
        self.status = status
        self.state = state
        self.currencies = currencies
        self.tags = tags
        self.tiers = tiers
        self.needsDocumentResubmission = needsDocumentResubmission
        self.userName = userName
        self.depositAddresses = depositAddresses
        self.productsUsed = productsUsed
        self.settings = settings
        self.kycCreationDate = kycCreationDate
        self.kycUpdateDate = kycUpdateDate
        self.unifiedAccountWalletGuid = unifiedAccountWalletGuid
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decode(String.self, forKey: .identifier)
        self.address = try values.decodeIfPresent(UserAddress.self, forKey: .address)
        self.tiers = try values.decodeIfPresent(KYC.UserState.self, forKey: .tiers)
        self.userName = try values.decodeIfPresent(String.self, forKey: .userName)
        self.productsUsed = try values.decodeIfPresent(ProductsUsed.self, forKey: .productsUsed)
        self.settings = try values.decodeIfPresent(NabuUserSettings.self, forKey: .settings)
        self.personalDetails = try PersonalDetails(from: decoder)
        self.email = try Email(from: decoder)
        self.currencies = try values.decode(Currencies.self, forKey: .currencies)
        self.mobile = try? Mobile(from: decoder)
        self.status = (try? values.decode(KYC.AccountStatus.self, forKey: .status)) ?? .none
        self.state = (try? values.decode(UserState.self, forKey: .state)) ?? .none
        self.tags = try values.decodeIfPresent(Tags.self, forKey: .tags)
        self.needsDocumentResubmission = try values.decodeIfPresent(DocumentResubmission.self, forKey: .needsDocumentResubmission)
        self.kycCreationDate = try values.decodeIfPresent(String.self, forKey: .kycCreationDate)
        self.kycUpdateDate = try values.decodeIfPresent(String.self, forKey: .kycUpdateDate)

        self.depositAddresses = try (values.decodeIfPresent([String: String].self, forKey: .depositAddresses))
            .flatMap { data -> [DepositAddress] in
                data.compactMap { key, value -> DepositAddress? in
                    DepositAddress(stringType: key, address: value)
                }
            } ?? []

        self.unifiedAccountWalletGuid = try values.decodeIfPresent(String.self, forKey: .unifiedAccountWalletGuid)
    }
}

extension NabuUser: User {}

extension NabuUser {
    /// User has a linked Exchange Account.
    ///
    /// If `ProductsUsed` property is present, use its `exchange` value.
    /// Else use value of `NabuUserSettings`s `mercuryEmailVerified`.
    /// Both `ProductsUsed` and `NabuUserSettings` are optionally present.
    public var hasLinkedExchangeAccount: Bool {
        if let productsUsed {
            return productsUsed.exchange
        } else if let mercuryEmailVerified = settings?.mercuryEmailVerified {
            return mercuryEmailVerified
        }
        return false
    }
}

extension NabuUser {

    public var isVerified: Bool {
        guard let tiers else { return false }
        return tiers.current == .verified
    }

    public var isCowboys: Bool {
        tags?.cowboys != nil
    }

    public var isSuperAppUser: Bool? {
        tags?.isSuperAppMvp
    }

    public var isSuperAppV1User: Bool? {
        tags?.isSuperAppV1
    }

    public var isCassyCardAlpha: Bool {
        guard BuildFlag.isAlpha else {
            return false
        }
        return tags?.isCassyCardAlpha != nil
    }
}

extension NabuUser: NabuUserBlockstackAirdropRegistering {
    public var isBlockstackAirdropRegistered: Bool {
        tags?.blockstack != nil
    }
}

public struct Mobile: Decodable, Equatable {
    public let phone: String
    public let verified: Bool

    private enum CodingKeys: String, CodingKey {
        case phone = "mobile"
        case verified = "mobileVerified"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.phone = try values.decode(String.self, forKey: .phone)
        self.verified = try values.decodeIfPresent(Bool.self, forKey: .verified) ?? false
    }

    public init(phone: String, verified: Bool) {
        self.phone = phone
        self.verified = verified
    }
}

struct Tags: Decodable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case blockstack = "BLOCKSTACK"
        case cowboys = "COWBOYS_2022"
        case isSuperAppMvpTrue = "is_superapp_mvp_true"
        case isSuperAppMvpFalse = "is_superapp_mvp_false"
        case isSuperAppV1True = "is_superapp_v1_true"
        case isSuperAppV1False = "is_superapp_v1_false"
        case cassyCardAlpha = "CARD_CASSY_ALPHA"
    }

    let blockstack: Blockstack?
    let cowboys: CodableVoid?
    var isSuperAppMvp: Bool?
    var isSuperAppV1: Bool?
    var isCassyCardAlpha: CodableVoid?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.blockstack = try values.decodeIfPresent(Blockstack.self, forKey: .blockstack)
        self.cowboys = try values.decodeIfPresent(CodableVoid.self, forKey: .cowboys)
        let isSuperAppMvpTrue = try values.decodeIfPresent(CodableVoid.self, forKey: .isSuperAppMvpTrue)
        let isSuperAppMvpFalse = try values.decodeIfPresent(CodableVoid.self, forKey: .isSuperAppMvpFalse)
        if isSuperAppMvpTrue != nil {
            self.isSuperAppMvp = true
        } else if isSuperAppMvpFalse != nil {
            self.isSuperAppMvp = false
        }

        let isSuperAppV1True = try values.decodeIfPresent(CodableVoid.self, forKey: .isSuperAppV1True)
        let isSuperAppV1False = try values.decodeIfPresent(CodableVoid.self, forKey: .isSuperAppV1False)
        if isSuperAppV1True != nil {
            self.isSuperAppV1 = true
        } else if isSuperAppV1False != nil {
            self.isSuperAppV1 = false
        }

        self.isCassyCardAlpha = try values.decodeIfPresent(CodableVoid.self, forKey: .cassyCardAlpha)
    }

    init(blockstack: Blockstack?, cowboys: CodableVoid?) {
        self.blockstack = blockstack
        self.cowboys = cowboys
    }

    struct Blockstack: Decodable, Equatable {
        let campaignAddress: String

        private enum CodingKeys: String, CodingKey {
            case campaignAddress = "x-campaign-address"
        }
    }
}

public struct DocumentResubmission: Decodable, Equatable {
    public let reason: Int

    private enum CodingKeys: String, CodingKey {
        case reason
    }
}

public struct DepositAddress: Equatable {
    public let type: CryptoCurrency
    public let address: String

    public init?(
        stringType: String,
        address: String,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        guard let type = enabledCurrenciesService.allEnabledCryptoCurrencies
            .first(where: { $0.code == stringType.uppercased() })
        else {
            return nil
        }
        self.init(type: type, address: address)
    }

    public init(type: CryptoCurrency, address: String) {
        self.type = type
        self.address = address
    }
}

public struct NabuUserSettings: Decodable, Equatable {
    public let mercuryEmailVerified: Bool?

    private enum CodingKeys: String, CodingKey {
        case mercuryEmailVerified = "MERCURY_EMAIL_VERIFIED"
    }

    public init(mercuryEmailVerified: Bool) {
        self.mercuryEmailVerified = mercuryEmailVerified
    }
}

public struct Currencies: Decodable, Equatable {
    public let preferredFiatTradingCurrency: FiatCurrency
    public let usableFiatCurrencies: [FiatCurrency]
    public let defaultWalletCurrency: FiatCurrency
    public let userFiatCurrencies: [FiatCurrency]
}
