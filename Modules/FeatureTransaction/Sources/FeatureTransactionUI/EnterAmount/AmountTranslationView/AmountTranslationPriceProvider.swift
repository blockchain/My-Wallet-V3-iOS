// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class AmountTranslationPriceProvider: AmountTranslationPriceProviding {

    private let transactionModel: TransactionModel

    init(transactionModel: TransactionModel) {
        self.transactionModel = transactionModel
    }

    func pairFromFiatInput(cryptoCurrency: CryptoCurrency, fiatCurrency: FiatCurrency, amount: String) -> Single<MoneyValuePair> {
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

    func pairFromCryptoInput(cryptoCurrency: CryptoCurrency, fiatCurrency: FiatCurrency, amount: String) -> Single<MoneyValuePair> {
        transactionModel
            .state
            .map(\.sourceToFiatPair)
            .filter { $0 != nil }
            .compactMap { $0 }
            .map { sourceToFiatPair -> MoneyValuePair in
                let amount = amount.isEmpty ? "0" : amount
                return MoneyValuePair(
                    base: CryptoValue.create(majorDisplay: amount, currency: cryptoCurrency)!.moneyValue,
                    exchangeRate: sourceToFiatPair.quote
                )
            }
            .take(1)
            .asSingle()
    }
}

extension TransactionState {

    var exchangeRate: MoneyValuePair? {
        guard let source, let destination else { return nil }
        guard let price else {
            return MoneyValuePair(
                base: MoneyValue.zero(currency: source.currencyType),
                quote: MoneyValue.zero(currency: destination.currencyType)
            )
        }
        do {
            let amount = try MoneyValue.create(minor: price.amount, currency: source.currencyType).or(throw: "No amount")
            let result = try MoneyValue.create(minor: price.result, currency: destination.currencyType).or(throw: "No result")
            return MoneyValuePair(base: amount, quote: result).exchangeRate
        } catch {
            return nil
        }
    }
}
