// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import Localization
import MoneyKit
import PlatformKit
import RxToolKit
import ToolKit

public protocol PaymentAccountsServiceAPI {

    /// Fetches the available payment methods for the current user and transforms them into `BlockchainAccount`s.
    /// - Parameters:
    ///   - currency: The target currency to buy using any of these payment methods. Currently unused.
    ///   - amount: The amount of currency to buy with any of these payment methods. Currently unused.
    func fetchPaymentMethodAccounts(
        for currency: CryptoCurrency,
        amount: MoneyValue
    ) -> AnyPublisher<[PaymentMethodAccount], NetworkError>
}

final class PaymentAccountsService: PaymentAccountsServiceAPI {

    let paymentMethodsService: PaymentMethodTypesServiceAPI
    let fiatCurrencyService: FiatCurrencyServiceAPI

    init(
        paymentMethodsService: PaymentMethodTypesServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.paymentMethodsService = paymentMethodsService
        self.fiatCurrencyService = fiatCurrencyService
    }

    func fetchPaymentMethodAccounts(
        for cryptoCurrency: CryptoCurrency,
        amount: MoneyValue
    ) -> AnyPublisher<[PaymentMethodAccount], NetworkError> {
        // STEP 1: Fetch the user's preferred currency. We'll need that to fetch payment methods with correct limits.
        fiatCurrencyService
            .tradingCurrency
            .setFailureType(to: NetworkError.self)
            .flatMap { tradingCurrency in
                // STEP 2: Fetch the payment methods using the fiat currency we got from the the user
                self.fetchPaymentMethodAccounts(
                    for: cryptoCurrency,
                    fiatCurrency: tradingCurrency,
                    amount: amount
                )
            }
            .eraseToAnyPublisher()
    }

    private func fetchPaymentMethodAccounts(
        for cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        amount: MoneyValue
    ) -> AnyPublisher<[PaymentMethodAccount], NetworkError> {
        // NOTE: currency and amount are ignored until new API is ready to use
        // STEP 1: Get all valid linked and linkable payment methods: this means, linked banks, linked cards, and payment methods.
        // Linked cards and banks are currently filtered for Buy. This should be improved.
        // Fetching payment methods is important as those contain the limits for the user.
        paymentMethodsService
            .paymentMethodTypesValidForBuy.eraseError()
            .zip(paymentMethodsService.eligiblePaymentMethods(for: fiatCurrency))
            .map { paymentMethodTypes, elibiblePaymentMethods -> [PaymentMethodAccount] in
                // Create `BlockchainAccount` types by merging a linked or linkable payment method, with it's payment method type metadata for limits
                let mappedPaymentMethods: [PaymentMethod] = elibiblePaymentMethods.compactMap { paymentMethodType in
                    // NOTE: Eligible payment methods are always of type `.suggested`
                    guard case .suggested(let rawPaymentMethod) = paymentMethodType else {
                        return nil
                    }
                    return rawPaymentMethod
                }
                return paymentMethodTypes.compactMap { paymentMethodType in
                    guard let paymentMethod = mappedPaymentMethods.first(where: {
                        paymentMethodType.method == $0.type
                    }) else {
                        Logger.shared.warning(
                            "⚠️⚠️⚠️ [\(#function)] Could not find payment method for \(paymentMethodType.method) ⚠️⚠️⚠️"
                        )
                        return nil
                    }
                    return PaymentMethodAccount(
                        paymentMethodType: paymentMethodType,
                        paymentMethod: paymentMethod
                    )
                }
            }
            .map { paymentAccounts in
                // If there are linked accounts - e.g. bank or card accounts, we don't need to return 'linkable' account types.
                if paymentAccounts.contains(where: { !$0.paymentMethodType.isSuggested }) {
                    // Filter out "suggested" (linkable) account types, so the user only sees accounts that are already linked.
                    // In this case, users can link new accounts by selecting the "Add" option in the source selection screen.
                    return paymentAccounts
                        .filter { !$0.paymentMethodType.isSuggested || $0.paymentMethod.type.isApplePay }
                }

                return paymentAccounts
            }
            .mapError { error in
                guard let networkError = error as? NetworkError else {
                    return NetworkError(request: nil, type: .authentication(error))
                }
                return networkError
            }
            .eraseToAnyPublisher()
    }
}
