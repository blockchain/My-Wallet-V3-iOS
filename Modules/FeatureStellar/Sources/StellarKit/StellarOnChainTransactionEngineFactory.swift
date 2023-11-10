// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import MoneyKit

final class StellarOnChainTransactionEngineFactory: OnChainTransactionEngineFactory {
    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let feeRepository: FeesRepositoryAPI
    let transactionDispatcher: StellarTransactionDispatcherAPI

    init(
        walletCurrencyService: FiatCurrencyServiceAPI,
        currencyConversionService: CurrencyConversionServiceAPI,
        feeRepository: FeesRepositoryAPI,
        transactionDispatcher: StellarTransactionDispatcherAPI
    ) {
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.transactionDispatcher = transactionDispatcher
        self.feeRepository = feeRepository
    }

    func build() -> OnChainTransactionEngine {
        StellarOnChainTransactionEngine(
            walletCurrencyService: walletCurrencyService,
            currencyConversionService: currencyConversionService,
            feeRepository: feeRepository,
            transactionDispatcher: transactionDispatcher
        )
    }
}
