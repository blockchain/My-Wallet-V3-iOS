// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCardPaymentDomain
import Foundation
import Frames
import ToolKit
import UIKit

class CheckoutClient: CardAcquirerClientAPI {

    private static let envKey = "CHECKOUT_ENV"
    private let apiKey: String
    private let client: CheckoutAPIService

    init(_ apiKey: String) {
        self.apiKey = apiKey

        guard let rawEnvironment = MainBundleProvider
            .mainBundle
            .infoDictionary?[Self.envKey] as? String,
            let environment = Environment(rawValue: rawEnvironment)
        else {
            self.client = CheckoutAPIService(publicKey: apiKey, environment: .sandbox)
            return
        }

        self.client = CheckoutAPIService(publicKey: apiKey, environment: environment)
    }

    func tokenize(_ card: CardData, accounts: [String]) -> AnyPublisher<CardTokenizationResponse, CardAcquirerError> {
        Deferred { [client] in
            Future<CardTokenizationResponse, CardAcquirerError> { promise in
                client.createToken(.card(card.checkoutParams)) { completion in
                    switch completion {
                    case .success(let response):
                        promise(.success(.init(token: response.token, accounts: accounts)))
                    case .failure(let error):
                        promise(.failure(.clientError(error)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    static func authorizationState(
        _ acquirer: ActivateCardResponse.CardAcquirer
    ) -> PartnerAuthorizationData.State {
        guard acquirer.paymentState == .waitingFor3DS,
              let paymentLink = acquirer.paymentLink,
              let paymentLinkURL = URL(string: paymentLink)
        else {
            return .confirmed
        }
        return .required(.init(cardAcquirer: .checkout, paymentLink: paymentLinkURL))
    }
}

extension CardData {
    var checkoutParams: Card {
        Card(
            number: number,
            expiryDate: .init(month: Int(month) ?? 0, year: Int(year) ?? 0),
            name: ownerName,
            cvv: cvv,
            billingAddress: billingAddress?.checkoutAddress,
            phone: nil
        )
    }
}

extension BillingAddress {
    var checkoutAddress: Frames.Address {
        Address(
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            city: city,
            state: state,
            zip: postCode,
            country: Country(iso3166Alpha2: country.code)
        )
    }
}
