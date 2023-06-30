// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Errors
import Foundation
import MoneyKit
import NetworkKit
import ToolKit

final class CardUpdateService: CardUpdateServiceAPI {

    // MARK: - Types

    enum ServiceError: Error {
        case unknownPartner
    }

    private enum CardUpdateEvent: AnalyticsEvent {
        case sbAddCardFailure
        case sbCardActivationFailure
        case sbCardEverypayFailure(data: String)

        var name: String {
            switch self {
            case .sbAddCardFailure:
                return "sb_add_card_failure"
            case .sbCardActivationFailure:
                return "sb_card_activation_failure"
            case .sbCardEverypayFailure:
                return "sb_card_everypay_failure"
            }
        }

        var params: [String: String]? {
            switch self {
            case .sbCardEverypayFailure(data: let data):
                return ["data": data]
            default:
                return nil
            }
        }
    }

    // MARK: - Injected

    private let cardClient: CardClientAPI
    private let everyPayClient: EveryPayClientAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let cardAcquirersRepository: CardAcquirersRepositoryAPI

    // MARK: - Setup

    init(
        cardClient: CardClientAPI = resolve(),
        everyPayClient: EveryPayClientAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        cardAcquirersRepository: CardAcquirersRepositoryAPI = resolve()
    ) {
        self.cardClient = cardClient
        self.everyPayClient = everyPayClient
        self.analyticsRecorder = analyticsRecorder
        self.cardAcquirersRepository = cardAcquirersRepository
    }

    func add(
        card: CardData,
        email: AnyPublisher<String, Never>,
        currency: AnyPublisher<FiatCurrency, Never>
    ) -> AnyPublisher<PartnerAuthorizationData, Error> {
        let cardAcquirerTokens = cardAcquirersRepository.tokenize(card)

        let params = Publishers.Zip3(
            currency,
            email,
            cardAcquirerTokens
        )
        .map { currency, email, tokens -> (currency: Currency, email: String, tokens: [String: String]) in
            (currency: currency, email: email, tokens: tokens)
        }

        // 1. Add the card details via BE
        let createCard = params
            .flatMap { [cardClient] payload -> AnyPublisher<CardPayload, NabuNetworkError> in
                cardClient
                    .add(
                        for: payload.currency.code,
                        email: payload.email,
                        billingAddress: card.billingAddress.requestPayload,
                        paymentMethodTokens: payload.tokens
                    )
                    .handleEvents(receiveCompletion: { [weak self] _ in
                        self?.analyticsRecorder.record(event: CardUpdateEvent.sbCardActivationFailure)
                    })
                    .eraseToAnyPublisher()
            }

        // 2. Activate the card
        typealias ActivationPayload = (cardId: String, partner: ActivateCardResponse.Partner)
        let activateCard =
            createCard.flatMap { [cardClient] payload -> AnyPublisher<ActivationPayload, NabuNetworkError> in
                cardClient.activateCard(
                    by: payload.identifier,
                    url: PartnerAuthorizationData.exitLink,
                    cvv: card.cvv
                )
                .map {
                    (cardId: payload.identifier, partner: $0)
                }
                .handleEvents(receiveCompletion: { [weak self] _ in
                    self?.analyticsRecorder.record(event: CardUpdateEvent.sbCardActivationFailure)
                })
                .eraseToAnyPublisher()
            }

        // 3. Authorize the card
        let authorizeCard = activateCard
            .mapError { $0 as Error }
            .flatMap { [weak self] payload -> AnyPublisher<PartnerAuthorizationData, Error> in
                guard let self else {
                    return .failure(CardAcquirerError.unknown)
                }
                return add(
                    card: card,
                    via: payload.partner
                )
                    .map {
                        PartnerAuthorizationData(
                            state: $0,
                            paymentMethodId: payload.cardId
                        )
                    }
                    .eraseToAnyPublisher()
            }

        return authorizeCard.eraseToAnyPublisher()
    }

    // MARK: - Partner Integration

    private func add(
        card: CardData,
        via partner: ActivateCardResponse.Partner
    ) -> AnyPublisher<PartnerAuthorizationData.State, Error> {
        switch partner {
        case .everypay(let data):
            return add(card: card, with: data).mapError { $0 as Error }.eraseToAnyPublisher()
        case .cardAcquirer(let acquirer):
            return add(card: card, via: acquirer)
        case .unknown:
            return .failure(ServiceError.unknownPartner)
        }
    }

    /// Add through acquirers
    private func add(
        card: CardData,
        via acquirer: ActivateCardResponse.CardAcquirer
    ) -> AnyPublisher<PartnerAuthorizationData.State, Error> {
        guard case .everyPay = acquirer.cardAcquirerName else {
            return cardAcquirersRepository.authorizationState(for: acquirer)
        }

        guard let apiUsername = acquirer.apiUserID,
              let mobileToken = acquirer.apiToken,
              let paymentLink = acquirer.paymentLink
        else {
            return .failure(CardAcquirerError.missingParameters)
        }
        return add(
            card: card,
            with: .init(
                apiUsername: apiUsername,
                mobileToken: mobileToken,
                paymentLink: paymentLink,
                paymentState: acquirer.paymentState.rawValue
            )
        )
        .mapError(CardAcquirerError.networkError)
        .eraseToAnyPublisher()
    }

    /// Add via every pay
    private func add(
        card: CardData,
        with everyPayData: ActivateCardResponse.Partner.EveryPayData
    ) -> AnyPublisher<PartnerAuthorizationData.State, NetworkError> {
        everyPayClient
            .send(
                cardDetails: card.everyPayCardDetails,
                apiUserName: everyPayData.apiUsername,
                token: everyPayData.mobileToken
            )
            .map { response -> PartnerAuthorizationData.State in
                switch response.status {
                case .waitingFor3DResponse:
                    let url = URL(string: everyPayData.paymentLink)!
                    return .required(.init(cardAcquirer: .everyPay, paymentLink: url))
                case .failed, .authorized, .settled, .waitingForBav:
                    return .none
                }
            }
            .handleEvents(receiveCompletion: { [weak self] error in
                self?.analyticsRecorder.record(
                    event: CardUpdateEvent.sbCardEverypayFailure(data: String(describing: error))
                )
            })
            .eraseToAnyPublisher()
    }
}

extension CardData {

    var everyPayCardDetails: CardPartnerPayload.EveryPay.SendCardDetailsRequest.CardDetails {
        .init(
            cardNumber: number,
            month: month,
            year: year,
            cardholderName: ownerName,
            cvv: cvv
        )
    }
}
