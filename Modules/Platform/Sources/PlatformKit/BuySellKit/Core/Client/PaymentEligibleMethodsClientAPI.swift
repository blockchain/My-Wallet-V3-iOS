// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardPaymentDomain

public protocol PaymentEligibleMethodsClientAPI: EligibleCardAcquirersAPI {

    func eligiblePaymentMethods(
        for currency: String,
        currentTier: KYC.Tier
    ) -> AnyPublisher<[PaymentMethodsResponse.Method], NabuNetworkError>
}
