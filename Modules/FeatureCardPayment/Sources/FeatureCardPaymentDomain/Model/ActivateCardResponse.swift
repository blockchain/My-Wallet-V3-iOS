// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct ActivateCardResponse: Decodable {

    public enum Partner {
        public struct EveryPayData: Decodable {
            public init(apiUsername: String, mobileToken: String, paymentLink: String, paymentState: String) {
                self.apiUsername = apiUsername
                self.mobileToken = mobileToken
                self.paymentLink = paymentLink
                self.paymentState = paymentState
            }

            public let apiUsername: String
            public let mobileToken: String
            public let paymentLink: String
            public let paymentState: String
        }

        case everypay(EveryPayData)
        case cardAcquirer(CardAcquirer)
        case unknown

        public var isKnown: Bool {
            switch self {
            case .unknown:
                return false
            default:
                return true
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case everypay
        case cardProvider
        case cardCassy
    }

    public enum PaymentState: String, Decodable {
        /// Should never happen. It means a case was forgotten by backend
        case initial = "INITIAL"

        /// We have to display a 3DS verification popup
        case waitingFor3DS = "WAITING_FOR_3DS_RESPONSE"

        /// 3DS valid
        case confirmed3DS = "CONFIRMED_3DS"

        /// Ready for capture, no need for 3DS
        case settled = "SETTLED"

        /// Payment voided
        case voided = "VOIDED"

        /// Payment abandonned
        case abandoned = "ABANDONED"

        /// Payment failed
        case failed = "FAILED"

        /// Just in case
        case unknown
    }

    public struct CardAcquirer: Decodable {
        public let cardAcquirerName: CardPayload.Acquirer
        public let cardAcquirerAccountCode: String
        public let apiUserID: String?
        public let apiToken: String?
        public let paymentLink: String?
        public let paymentState: PaymentState
        public let paymentReference: String?
        public let orderReference: String?
        public let clientSecret: String?
        public let publishableApiKey: String?

        public init(
            cardAcquirerName: CardPayload.Acquirer,
            cardAcquirerAccountCode: String,
            apiUserID: String?,
            apiToken: String?,
            paymentLink: String?,
            paymentState: String,
            paymentReference: String?,
            orderReference: String?,
            clientSecret: String?,
            publishableApiKey: String?
        ) {
            self.cardAcquirerName = cardAcquirerName
            self.cardAcquirerAccountCode = cardAcquirerAccountCode
            self.apiUserID = apiUserID
            self.apiToken = apiToken
            self.paymentLink = paymentLink
            self.paymentState = .init(rawValue: paymentState) ?? .unknown
            self.paymentReference = paymentReference
            self.orderReference = orderReference
            self.clientSecret = clientSecret
            self.publishableApiKey = publishableApiKey
        }
    }

    public let partner: Partner

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let cardProvider = try values.decodeIfPresent(CardAcquirer.self, forKey: .cardProvider)
        let cardCassy = try values.decodeIfPresent(CardAcquirer.self, forKey: .cardCassy)
        let acquirer = cardCassy ?? cardProvider

        if let data = try values.decodeIfPresent(Partner.EveryPayData.self, forKey: .everypay) {
            self.partner = .everypay(data)
        } else if let acquirer {
            self.partner = .cardAcquirer(acquirer)
        } else {
            self.partner = .unknown
        }
    }
}
