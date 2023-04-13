// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors

public struct CardPayload: Equatable, Hashable {

    public enum Partner: String {
        case everypay = "EVERYPAY"
        case cardProvider = "CARDPROVIDER"
        case cassy = "CARD_CASSY"
        case unknown

        public var isKnown: Bool {
            self != .unknown
        }
    }

    /// The id of the card
    public let identifier: String

    /// The partner of the card
    public let partner: CardPayload.Partner

    /// The billing address
    public let address: BillingAddress!

    /// The currency of the card
    public let currency: String

    /// The state (e.g: PENDING)
    public let state: State

    /// The details on the card
    public let card: CardDetails!

    /// The addition date (e.g: `2020-04-07T23:23:26.761Z`)
    public let additionDate: String

    public let lastError: String?
    public let ux: UX.Dialog?
    public let block: Bool

    public init(
        identifier: String,
        partner: String,
        address: BillingAddress!,
        currency: String,
        state: State,
        card: CardDetails!,
        additionDate: String,
        block: Bool = false,
        lastError: String? = nil,
        ux: UX.Dialog? = nil
    ) {
        self.identifier = identifier
        self.partner = Partner(rawValue: partner) ?? .unknown
        self.address = address
        self.currency = currency
        self.state = state
        self.card = card
        self.additionDate = additionDate
        self.lastError = lastError
        self.block = block
        self.ux = ux
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(partner)
        hasher.combine(state)
        hasher.combine(currency)
        hasher.combine(card)
    }
}

// MARK: - Decodable

extension CardPayload: Codable {

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case partner
        case address
        case currency
        case state
        case card
        case additionDate = "addedAt"
        case lastError
        case block
        case ux
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decode(String.self, forKey: .identifier)

        let partnerString = try values.decode(String.self, forKey: .partner)
        self.partner = Partner(rawValue: partnerString) ?? .unknown

        self.address = try values.decodeIfPresent(BillingAddress.self, forKey: .address)
        self.currency = try values.decode(String.self, forKey: .currency)

        self.state = try values.decodeIfPresent(State.self, forKey: .state) ?? .none

        self.additionDate = try values.decode(String.self, forKey: .additionDate)

        self.block = try values.decodeIfPresent(Bool.self, forKey: .block) ?? false
        self.card = try values.decodeIfPresent(CardDetails.self, forKey: .card)
        self.lastError = try? values.decodeIfPresent(String.self, forKey: .lastError)
        self.ux = try? values.decodeIfPresent(UX.Dialog.self, forKey: .ux)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(partner.rawValue, forKey: .partner)
        try container.encode(address, forKey: .address)
        try container.encode(state, forKey: .state)
        try container.encode(additionDate, forKey: .additionDate)
        try container.encode(block, forKey: .block)
        try container.encode(card, forKey: .card)
        try container.encodeIfPresent(lastError, forKey: .lastError)
        try container.encodeIfPresent(ux, forKey: .ux)
    }
}

// MARK: - Types

extension CardPayload {

    /// The card details
    public struct CardDetails: Equatable, Hashable {

        /// e.g `1234` (4 digits)
        public let number: String

        /// e.g `10`
        public let month: String?

        /// e.g `2021`
        public let year: String?

        /// e.g: `MASTERCARD`
        public let type: String?

        /// e.g: `AS LHV BANK`
        public let label: String
    }

    /// The partner for the card
    public enum Acquirer: String, Codable, Equatable {

        /// EveryPay partner
        case everyPay = "EVERYPAY"

        /// Stripe partner
        case stripe = "STRIPE"

        /// Checkout.com partner
        case checkout = "CHECKOUTDOTCOM"

        /// For testing
        case fake = "FAKE_CARD_ACQUIRER"

        /// Any other
        case unknown

        public var isKnown: Bool {
            switch self {
            case .unknown:
                return false
            default:
                return true
            }
        }

        public init(acquirer: String) {
            self = Acquirer(rawValue: acquirer) ?? .unknown
        }
    }

    /// The state for a card
    public enum State: String, Codable {

        // Initial card state
        case none = "NONE"

        // Waiting for activation
        case pending = "PENDING"

        // Card ready to be used
        case active = "ACTIVE"

        // Card created
        case created = "CREATED"

        // Blocked for fraud or other reason
        case blocked = "BLOCKED"

        /// Card under manual review
        case manualReview = "MANUAL_REVIEW"

        /// The card is under fraud review
        case fraudReview = "FRAUD_REVIEW"

        // Card is expired
        case expired = "EXPIRED"

        /// Card is active
        var isActive: Bool {
            switch self {
            case .active:
                return true
            default:
                return false
            }
        }

        /// This is `true` if the card is usable (created on BE, and was or is in a
        /// usable state.
        public var isUsable: Bool {
            switch self {
            case .active, .blocked, .expired, .fraudReview, .manualReview:
                return true
            case .created, .none, .pending:
                return false
            }
        }
    }

    /// The billing address for a card
    public struct BillingAddress: Codable, Equatable {
        public let line1: String
        public let line2: String?
        public let postCode: String
        public let city: String
        public let state: String?
        public let country: String
    }
}

extension CardPayload.CardDetails: Codable {

    private enum CodingKeys: String, CodingKey {
        case number
        case expireMonth
        case expireYear
        case type
        case label
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        number = try values.decode(String.self, forKey: .number)

        if let month = try values.decodeIfPresent(Int.self, forKey: .expireMonth) {
            self.month = String(format: "%02d", month)
        } else {
            month = nil
        }

        if let year = try values.decodeIfPresent(Int.self, forKey: .expireYear) {
            self.year = "\(year)"
        } else {
            year = nil
        }

        type = try values.decodeIfPresent(String.self, forKey: .type)
        label = try values.decodeIfPresent(String.self, forKey: .label) ?? ""
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        if let month {
            try container.encode(Int(month), forKey: .expireMonth)
        }
        if let year {
            try container.encode(Int(year), forKey: .expireYear)
        }
        try container.encode(type, forKey: .type)
        try container.encode(label, forKey: .label)
    }
}
