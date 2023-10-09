// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit

/// Used to create a pending order when the user confirms the transaction
public protocol OrderCreationServiceAPI: AnyObject {
    func create(using candidateOrderDetails: CandidateOrderDetails) -> AnyPublisher<CheckoutData, Error>
}

final class OrderCreationService: OrderCreationServiceAPI {

    // MARK: - Service Error

    enum ServiceError: Error {
        case mappingError
    }

    // MARK: - Properties

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let client: OrderCreationClientAPI

    // MARK: - Setup

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        client: OrderCreationClientAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
    }

    // MARK: - API

    func create(using candidateOrderDetails: CandidateOrderDetails) -> AnyPublisher<CheckoutData, Error> {
        let data = OrderPayload.Request(
            quoteId: candidateOrderDetails.quoteId,
            action: candidateOrderDetails.action,
            fiatValue: candidateOrderDetails.fiatValue,
            fiatCurrency: candidateOrderDetails.fiatCurrency,
            cryptoValue: candidateOrderDetails.cryptoValue,
            paymentType: candidateOrderDetails.paymentMethod?.method,
            paymentMethodId: candidateOrderDetails.paymentMethodId,
            period: candidateOrderDetails.recurringBuyFrequency
        )
        return client
            .create(
                order: data,
                createPendingOrder: true
            )
            .map { [analyticsRecorder] response in
                OrderDetails(recorder: analyticsRecorder, response: response)
            }
            .tryMap { details -> OrderDetails in
                guard let details else {
                    throw ServiceError.mappingError
                }
                return details
            }
            .map { CheckoutData(order: $0) }
            .eraseError()
            .eraseToAnyPublisher()
    }
}
