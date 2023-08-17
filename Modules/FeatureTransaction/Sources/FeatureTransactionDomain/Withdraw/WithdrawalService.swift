// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Blockchain
import Dependencies
import MoneyKit
import PlatformKit
import RxSwift

final class WithdrawalService: WithdrawalServiceAPI {

    @Dependency(\.app) var app

    private let client: WithdrawalClientAPI
    private let transactionLimitsService: TransactionLimitsServiceAPI

    init(
        client: WithdrawalClientAPI,
        transactionLimitsService: TransactionLimitsServiceAPI
    ) {
        self.client = client
        self.transactionLimitsService = transactionLimitsService
    }

    func withdrawFeeAndLimit(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<WithdrawalFeeAndLimit> {
        app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self)
            .replaceError(with: false)
            .asSingle()
            .flatMap { [client, transactionLimitsService] isEligible -> Single<WithdrawalFeeAndLimit> in
                client.withdrawFee(currency: currency, paymentMethodType: paymentMethodType, product: isEligible ? "EXTERNAL_BROKERAGE" : "SIMPLEBUY")
                    .map { response -> (CurrencyFeeResponse, CurrencyFeeResponse) in
                        guard let fees = response.fees.first(where: { $0.symbol == currency.code }) else {
                            fatalError("Expected fees for currency: \(currency)")
                        }
                        guard let mins = response.minAmounts.first(where: { $0.symbol == currency.code }) else {
                            fatalError("Expected minimum values for currency: \(currency)")
                        }
                        return (fees, mins)
                    }
                    .mapError(TransactionLimitsServiceError.network)
                    .zip(
                        transactionLimitsService.fetchLimits(
                            source: LimitsAccount(
                                currency: currency.currencyType,
                                accountType: .custodial
                            ),
                            destination: LimitsAccount(
                                currency: currency.currencyType,
                                accountType: .nonCustodial
                            ),
                            limitsCurrency: currency
                        )
                    )
                    .map { withdrawData, limitsData -> WithdrawalFeeAndLimit in
                        let (feeResponse, minResponse) = withdrawData
                        let zero: FiatValue = .zero(currency: currency)
                        return WithdrawalFeeAndLimit(
                            maxLimit: limitsData.maximum?.fiatValue,
                            minLimit: FiatValue.create(minor: minResponse.minorValue, currency: currency) ?? zero,
                            fee: FiatValue.create(minor: feeResponse.minorValue, currency: currency) ?? zero
                        )
                    }
                    .asSingle()
            }
    }

    func withdrawalFee(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        withdrawFeeAndLimit(for: currency, paymentMethodType: paymentMethodType)
            .map(\.fee)
    }

    func withdrawalMinAmount(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        withdrawFeeAndLimit(for: currency, paymentMethodType: paymentMethodType)
            .map(\.minLimit)
    }

    func withdrawal(for checkout: WithdrawalCheckoutData) -> Single<Result<FiatValue, Error>> {
        app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self)
            .replaceError(with: false)
            .asSingle()
            .flatMap { [client] isEligible -> Single<Result<FiatValue, Error>> in
                client.withdraw(data: checkout, product: isEligible ? "EXTERNAL_BROKERAGE" : "SIMPLEBUY")
                    .asSingle()
                    .mapToResult { response -> FiatValue in
                        guard let amount = FiatValue.create(major: response.amount.value, currency: checkout.currency) else {
                            fatalError("Couldn't create FiatValue from withdrawal response: \(response)")
                        }
                        return amount
                    }
            }
    }
}
