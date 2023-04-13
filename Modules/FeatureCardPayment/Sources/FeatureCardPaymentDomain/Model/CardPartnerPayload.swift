// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CombineExtensions
import Foundation

/// The payload for the card partner (network request / response)
public enum CardPartnerPayload {

    public enum EveryPay {

        public struct SendCardDetailsRequest: Encodable {
            public init(
                apiUserName: String,
                nonce: String,
                timestamp: String,
                cardDetails: CardPartnerPayload.EveryPay.SendCardDetailsRequest.CardDetails
            ) {
                self.apiUserName = apiUserName
                self.nonce = nonce
                self.timestamp = timestamp
                self.cardDetails = cardDetails
            }

            public struct CardDetails: Encodable {
                public init(cardNumber: String, month: String, year: String, cardholderName: String, cvv: String) {
                    self.cardNumber = cardNumber
                    self.month = month
                    self.year = year
                    self.cardholderName = cardholderName
                    self.cvv = cvv
                }

                private enum CodingKeys: String, CodingKey {
                    case cardNumber = "cc_number"
                    case month
                    case year
                    case cardholderName = "holder_name"
                    case cvv = "cvc"
                }

                public let cardNumber: String
                public let month: String
                public let year: String
                public let cardholderName: String
                public let cvv: String
            }

            private enum CodingKeys: String, CodingKey {
                case cardDetails = "cc_details"
                case apiUserName = "api_username"
                case tokenConsented = "token_consented"
                case nonce
                case timestamp
            }

            public let apiUserName: String
            public let nonce: String
            public let timestamp: String
            public let cardDetails: CardDetails
            public let tokenConsented = true
        }

        public struct CardDetailsResponse: Decodable {

            public enum Status: String, Decodable {
                case failed
                case authorized
                case settled
                case waitingForBav = "waiting_for_bav"
                case waitingFor3DResponse = "waiting_for_3ds_response"
            }

            private enum CodingKeys: String, CodingKey {
                case error = "processing_errors"
                case status = "payment_state"
            }

            public let status: Status
            @Optional.Codable public var error: String?
        }
    }
}
