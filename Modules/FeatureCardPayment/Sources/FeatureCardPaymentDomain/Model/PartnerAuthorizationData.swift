// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PartnerAuthorizationData: Equatable {
    public init(state: PartnerAuthorizationData.State, paymentMethodId: String) {
        self.state = state
        self.paymentMethodId = paymentMethodId
    }

    public static var exitLink = "https://www.blockchain.com/"

    /// Required authorization type
    public enum State: Equatable {
        public struct PaymentParams: Equatable {
            public let cardAcquirer: CardPayload.Acquirer
            public let clientSecret: String?
            public let publishableApiKey: String?
            public let paymentLink: URL?
            public let exitLink: URL

            public init(
                cardAcquirer: CardPayload.Acquirer,
                clientSecret: String? = nil,
                paymentLink: URL? = nil,
                publishableApiKey: String? = nil
            ) {
                self.cardAcquirer = cardAcquirer
                self.paymentLink = paymentLink
                self.clientSecret = clientSecret
                self.publishableApiKey = publishableApiKey
                self.exitLink = URL(string: PartnerAuthorizationData.exitLink)!
            }
        }

        /// Requires user user authorization by visiting the associated link
        case required(PaymentParams)

        /// Confirmed authorization
        case confirmed

        /// Authorized to proceed - no auth required
        case none

        public var isRequired: Bool {
            switch self {
            case .required:
                true
            case .confirmed, .none:
                false
            }
        }

        public var isConfirmed: Bool {
            switch self {
            case .confirmed:
                true
            case .required, .none:
                false
            }
        }
    }

    /// The type of required authorization
    public let state: State

    /// The payment method id that needs to be authorized
    public let paymentMethodId: String
}

public protocol OrderPayloadResponseAPI {
    var paymentMethodId: String? { get }
    var authorizationState: PartnerAuthorizationData.State { get }
}

extension PartnerAuthorizationData {
    public init?(orderPayloadResponse: OrderPayloadResponseAPI) {
        guard let paymentMethodId = orderPayloadResponse.paymentMethodId else {
            return nil
        }
        self.paymentMethodId = paymentMethodId
        self.state = orderPayloadResponse.authorizationState
    }
}
