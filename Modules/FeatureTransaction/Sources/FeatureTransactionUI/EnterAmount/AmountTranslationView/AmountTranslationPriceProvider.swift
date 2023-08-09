// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

public protocol AmountTranslationPriceProviding {
    // Amount is in Fiat, must return an MoneyValuePair of base `amount` in `fiatCurrency` and the quoted crypto value.
    func pairFromFiatInput(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        amount: String
    ) -> Single<MoneyValuePair>

    // Amount is in Crypto, must return an MoneyValuePair of base `amount` in `cryptoCurrency` and the quoted fiat value.
    func pairFromCryptoInput(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        amount: String
    ) -> Single<(base: MoneyValue, quote: MoneyValue?)>
}

final class AmountTranslationPriceProvider: AmountTranslationPriceProviding {

    private let transactionModel: TransactionModel

    init(transactionModel: TransactionModel) {
        self.transactionModel = transactionModel
    }

    func pairFromFiatInput(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        amount: String
    ) -> Single<MoneyValuePair> {
        transactionModel
            .state
            .map(\.sourceToFiatPair)
            .filter { $0 != nil }
            .compactMap { $0 }
            .map { sourceToFiatPair -> MoneyValuePair in
                let amount = amount.isEmpty ? "0" : amount
                return MoneyValuePair(
                    fiatValue: FiatValue.create(majorDisplay: amount, currency: fiatCurrency)!,
                    exchangeRate: sourceToFiatPair.quote.fiatValue!,
                    cryptoCurrency: cryptoCurrency,
                    usesFiatAsBase: true
                )
            }
            .take(1)
            .asSingle()
    }

    func pairFromCryptoInput(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        amount: String
    ) -> Single<(base: MoneyValue, quote: MoneyValue?)> {
        transactionModel
            .state
            .map(\.sourceToFiatPair)
            .map { sourceToFiatPair -> (base: MoneyValue, quote: MoneyValue?) in
                let amount = amount.isEmpty ? "0" : amount
                let base = CryptoValue
                    .create(majorDisplay: amount, currency: cryptoCurrency)!
                    .moneyValue
                return (base: base, quote: sourceToFiatPair?.quote)
            }
            .take(1)
            .asSingle()
    }
}
