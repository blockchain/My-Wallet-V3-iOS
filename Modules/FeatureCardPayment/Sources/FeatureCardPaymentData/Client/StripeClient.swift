// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureCardPaymentDomain
import Foundation
import StripePayments
import UIKit

public class StripeClient: CardAcquirerClientAPI {
    enum StripeError: Error {
        case emptyToken
        case emptyIntent
        case emptyMethod
    }

    private let apiKey: String
    private let client: STPAPIClient

    init(_ apiKey: String) {
        self.apiKey = apiKey
        self.client = STPAPIClient(publishableKey: apiKey)
    }

    public func tokenize(_ card: CardData, accounts: [String]) -> AnyPublisher<CardTokenizationResponse, CardAcquirerError> {
        Deferred { [client] in
            Future<CardTokenizationResponse, CardAcquirerError> { promise in
                client.createPaymentMethod(with: card.stripeParams) { method, error in
                    guard let method else {
                        promise(.failure(.clientError(error ?? StripeError.emptyMethod)))
                        return
                    }
                    promise(.success(.init(token: method.stripeId, accounts: accounts)))
                }
            }
        }.eraseToAnyPublisher()
    }

    public static func authorizationState(
        _ acquirer: ActivateCardResponse.CardAcquirer
    ) -> PartnerAuthorizationData.State {
        guard acquirer.paymentState == .waitingFor3DS,
              let clientSecret = acquirer.clientSecret,
              let publishableApiKey = acquirer.publishableApiKey
        else {
            return .confirmed
        }
        return .required(.init(
            cardAcquirer: .stripe,
            clientSecret: clientSecret,
            publishableApiKey: publishableApiKey
        ))
    }
}

extension CardData {
    fileprivate var stripeParams: STPPaymentMethodParams {
        let card = STPPaymentMethodCardParams()
        card.number = number
        card.cvc = cvv
        card.expMonth = NSNumber(value: Int(month)!)
        card.expYear = NSNumber(value: Int(year)!)

        let billingDetails = STPPaymentMethodBillingDetails()
        billingDetails.name = ownerName
        billingDetails.address = billingAddress?.stripeAddress

        return STPPaymentMethodParams(card: card, billingDetails: billingDetails, metadata: nil)
    }
}

extension BillingAddress {
    fileprivate var stripeAddress: STPPaymentMethodAddress {
        let address = STPPaymentMethodAddress()
        address.line1 = addressLine1
        address.line2 = addressLine2
        address.country = country.code
        address.city = city
        address.state = state
        address.postalCode = postCode
        return address
    }
}
