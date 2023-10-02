// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxSwift

final class MockWithdrawalServiceAPI: WithdrawalServiceAPI {

    func withdrawFeeAndLimit(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<WithdrawalFeeAndLimit> {
        .just(.init(
            maxLimit: .zero(currency: currency),
            minLimit: .zero(currency: currency),
            fee: .zero(currency: currency)
        ))
    }

    func withdrawal(
        for checkout: WithdrawalCheckoutData
    ) -> Single<Result<FiatValue, Error>> {
        fatalError("Not implemented")
    }

    func withdrawalFee(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        fatalError("Not implemented")
    }

    func withdrawalMinAmount(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        fatalError("Not implemented")
    }
}
