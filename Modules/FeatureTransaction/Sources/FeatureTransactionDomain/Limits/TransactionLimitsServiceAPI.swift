// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import Errors
import MoneyKit
import PlatformKit
import ToolKit

public typealias TransactionLimitsServicePublisher = AnyPublisher<TransactionLimits, TransactionLimitsServiceError>

public enum TransactionLimitsServiceError: Error {
    case network(NabuNetworkError)
    case other(Error)
}

/// Use this service to fetch the limits for any kind of trade the logged-in user can perform.
/// This service is meant to be used by `TransactionEngine`s to fetch limits data that can be used to create or update `PendingTransaction`s.
public protocol TransactionLimitsServiceAPI {

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount
    ) -> TransactionLimitsServicePublisher

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: FiatCurrency
    ) -> TransactionLimitsServicePublisher

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        product: TransactionLimitsProduct
    ) -> TransactionLimitsServicePublisher

    func fetchLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType,
        product: TransactionLimitsProduct
    ) -> TransactionLimitsServicePublisher
}

final class TransactionLimitsService: TransactionLimitsServiceAPI {

    private let repository: TransactionLimitsRepositoryAPI
    private let conversionService: CurrencyConversionServiceAPI
    private let walletCurrencyService: FiatCurrencyServiceAPI

    init(
        repository: TransactionLimitsRepositoryAPI,
        conversionService: CurrencyConversionServiceAPI,
        walletCurrencyService: FiatCurrencyServiceAPI
    ) {
        self.repository = repository
        self.conversionService = conversionService
        self.walletCurrencyService = walletCurrencyService
    }

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount
    ) -> TransactionLimitsServicePublisher {
        walletCurrencyService.displayCurrencyPublisher
            .setFailureType(to: TransactionLimitsServiceError.self)
            .flatMap { [unowned self] walletCurrency -> TransactionLimitsServicePublisher in
                fetchLimits(source: source, destination: destination, limitsCurrency: walletCurrency)
                    .convertAmounts(
                        from: walletCurrency.currencyType,
                        to: source.currency,
                        using: conversionService
                    )
            }
            .eraseToAnyPublisher()
    }

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: FiatCurrency
    ) -> TransactionLimitsServicePublisher {
        fetchCrossBorderLimits(
            source: source,
            destination: destination,
            limitsCurrency: limitsCurrency
        )
    }

    func fetchLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        product: TransactionLimitsProduct
    ) -> TransactionLimitsServicePublisher {
        walletCurrencyService.displayCurrencyPublisher
            .flatMap { [unowned self] walletCurrency -> TransactionLimitsServicePublisher in
                let convertedTradeLimits = fetchTradeLimits(
                    fiatCurrency: walletCurrency,
                    destination: destination,
                    product: product
                )
                    .convertAmounts(
                        from: walletCurrency.currencyType,
                        to: source.currency,
                        using: conversionService
                    )
                    .eraseToAnyPublisher()

                let convertedCrossBorderLimits = fetchCrossBorderLimits(
                    source: source,
                    destination: destination,
                    limitsCurrency: walletCurrency
                )
                    .convertAmounts(
                        from: walletCurrency.currencyType,
                        to: source.currency,
                        using: conversionService
                    )
                return Publishers.Zip(convertedTradeLimits, convertedCrossBorderLimits)
                    .map { $0.merge(with: $1) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func fetchLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType,
        product: TransactionLimitsProduct
    ) -> TransactionLimitsServicePublisher {
        fetchTradeLimits(
            fiatCurrency: paymentMethod.fiatCurrency,
            destination: LimitsAccount(
                currency: targetCurrency,
                accountType: .custodial
            ),
            product: product
        )
        .flatMap { [conversionService] tradeLimits -> TransactionLimitsServicePublisher in
            let limits = tradeLimits.merge(with: TransactionLimits(paymentMethod))
            return .just(limits)
                .convertAmounts(
                    from: tradeLimits.currencyType,
                    to: limitsCurrency,
                    using: conversionService
                )
        }
        .catchInactiveUserError(limitsCurrency: limitsCurrency)
        .flatMap { [unowned self] transactionLimits in
            fetchCrossBorderLimits(
                for: paymentMethod,
                targetCurrency: targetCurrency,
                limitsCurrency: limitsCurrency
            )
            .map { crossBorderLimits -> TransactionLimits in
                transactionLimits.merge(with: crossBorderLimits)
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Helpers

extension TransactionLimitsService {

    private func fetchTradeLimits(
        fiatCurrency: FiatCurrency,
        destination: LimitsAccount,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<TransactionLimits, TransactionLimitsServiceError> {
        repository
            .fetchTradeLimits(
                sourceCurrency: fiatCurrency.currencyType,
                product: product
            )
            .mapError(TransactionLimitsServiceError.network)
            .map(TransactionLimits.init)
            .eraseToAnyPublisher()
    }

    private func fetchCrossBorderLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: FiatCurrency
    ) -> AnyPublisher<TransactionLimits, TransactionLimitsServiceError> {
        repository
            .fetchCrossBorderLimits(
                source: source,
                destination: destination,
                limitsCurrency: limitsCurrency
            )
            .mapError(TransactionLimitsServiceError.network)
            .map(TransactionLimits.init)
            .eraseToAnyPublisher()
    }

    private func fetchCrossBorderLimits(
        for paymentMethod: PaymentMethod,
        targetCurrency: CurrencyType,
        limitsCurrency: CurrencyType
    ) -> TransactionLimitsServicePublisher {
        fetchCrossBorderLimits(
            source: LimitsAccount(
                currency: paymentMethod.fiatCurrency.currencyType,
                accountType: paymentMethod.type.isFunds ? .custodial : .nonCustodial
            ),
            destination: LimitsAccount(
                currency: targetCurrency,
                accountType: .custodial
            ),
            limitsCurrency: paymentMethod.fiatCurrency
        )
        .map { crossBorderLimits -> TransactionLimits in
            TransactionLimits.merge(
                paymentMethod: paymentMethod,
                with: crossBorderLimits,
                usePaymentMethodMax: targetCurrency.isFiatCurrency // is true means this is for deposits
            )
        }
        .convertAmounts(
            from: paymentMethod.fiatCurrency.currencyType,
            to: limitsCurrency,
            using: conversionService
        )
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TransactionLimits, Failure == TransactionLimitsServiceError {

    fileprivate func catchInactiveUserError(limitsCurrency: CurrencyType) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            switch error {
            case .network(let error) where error.code == .userNotActive:
                return .just(.zero(for: limitsCurrency))
            default:
                return .failure(error)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TransactionLimits, Failure == TransactionLimitsServiceError {

    func convertAmounts(
        from fromCurrency: CurrencyType,
        to toCurrency: CurrencyType,
        using conversionService: CurrencyConversionServiceAPI
    ) -> TransactionLimitsServicePublisher {
        zip(
            conversionService
                .conversionRate(from: fromCurrency, to: toCurrency)
                .mapError(TransactionLimitsServiceError.other)
        )
        .map { originalLimits, exchangeRate -> TransactionLimits in
            originalLimits.convert(using: exchangeRate)
        }
        .eraseToAnyPublisher()
    }
}

extension TransactionLimits {

    fileprivate init(_ tradeLimits: TradeLimits) {
        self.init(
            currencyType: tradeLimits.currency,
            minimum: tradeLimits.minOrder,
            maximum: tradeLimits.maxPossibleOrder,
            maximumDaily: tradeLimits.daily?.limit ?? tradeLimits.maxPossibleOrder,
            maximumAnnual: tradeLimits.annual?.limit ?? tradeLimits.maxPossibleOrder,
            effectiveLimit: .init(timeframe: .single, value: tradeLimits.maxPossibleOrder),
            suggestedUpgrade: nil,
            earn: nil
        )
    }

    init(_ paymentMethod: PaymentMethod) {
        self.init(
            currencyType: paymentMethod.fiatCurrency.currencyType,
            minimum: paymentMethod.min.moneyValue,
            maximum: paymentMethod.max.moneyValue,
            maximumDaily: paymentMethod.maxDaily.moneyValue,
            maximumAnnual: paymentMethod.maxAnnual.moneyValue,
            effectiveLimit: .init(timeframe: .single, value: paymentMethod.max.moneyValue),
            suggestedUpgrade: nil,
            earn: nil
        )
    }

    fileprivate init(_ crossBorderLimits: CrossBorderLimits) {
        let effectiveLimit: EffectiveLimit?
        if let maxCurrentLimit = crossBorderLimits.currentLimits?.available {
            effectiveLimit = .init(crossBorderLimits: crossBorderLimits, maxLimitFallbak: maxCurrentLimit)
        } else {
            effectiveLimit = nil
        }
        self.init(
            currencyType: crossBorderLimits.currency,
            minimum: .zero(currency: crossBorderLimits.currency),
            maximum: crossBorderLimits.currentLimits?.available,
            maximumDaily: crossBorderLimits.currentLimits?.daily?.limit,
            maximumAnnual: crossBorderLimits.currentLimits?.yearly?.limit,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: crossBorderLimits.suggestedUpgrade,
            earn: nil
        )
    }

    fileprivate func merge(with limits: TransactionLimits) -> TransactionLimits {
        guard currencyType == limits.currencyType else {
            fatalError("Merging limits with mismatching currency types is not allowed")
        }

        let effectiveLimit: EffectiveLimit? = try? .min(effectiveLimit, limits.effectiveLimit)
        let suggestedUpgrade: SuggestedLimitsUpgrade?
        if let lhs = effectiveLimit, let rhs = limits.effectiveLimit {
            suggestedUpgrade = try? lhs.value > rhs.value ? self.suggestedUpgrade : limits.suggestedUpgrade
        } else {
            suggestedUpgrade = self.suggestedUpgrade ?? limits.suggestedUpgrade
        }

        let defaultMin = limits.minimum ?? minimum
        let defaultMax = limits.maximum ?? maximum
        let combinedMax = (try? .min(limits.maximum, maximum)) ?? defaultMax
        let defaultMaxDaily = limits.maximumDaily ?? maximumDaily ?? combinedMax
        let defaultMaxAnnual = limits.maximumAnnual ?? maximumAnnual ?? defaultMaxDaily

        return TransactionLimits(
            currencyType: limits.currencyType,
            minimum: (try? .max(limits.minimum, minimum)) ?? defaultMin,
            maximum: combinedMax,
            maximumDaily: (try? .min(limits.maximumDaily, maximumDaily)) ?? defaultMaxDaily,
            maximumAnnual: (try? .min(limits.maximumAnnual, maximumAnnual)) ?? defaultMaxAnnual,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: suggestedUpgrade,
            earn: limits.earn
        )
    }

    fileprivate static func merge(
        paymentMethod: PaymentMethod,
        with crossBorderLimits: TransactionLimits,
        usePaymentMethodMax: Bool
    ) -> TransactionLimits {
        let maxCrossBorderCurrentLimit = crossBorderLimits.maximum ?? paymentMethod.max.moneyValue
        let maxLimit: MoneyValue
        if usePaymentMethodMax, let m = try? MoneyValue.min(paymentMethod.max.moneyValue, maxCrossBorderCurrentLimit) {
            maxLimit = m
        } else {
            maxLimit = maxCrossBorderCurrentLimit
        }
        let maxCrossBorderDailyLimit = crossBorderLimits.maximumDaily ?? maxLimit
        let maxCrossBorderAnnualLimit = crossBorderLimits.maximumAnnual ?? maxCrossBorderDailyLimit
        let effectiveLimit = crossBorderLimits.effectiveLimit ?? EffectiveLimit(timeframe: .single, value: maxLimit)
        return TransactionLimits(
            currencyType: crossBorderLimits.currencyType,
            minimum: paymentMethod.min.moneyValue,
            maximum: maxLimit,
            maximumDaily: maxCrossBorderDailyLimit,
            maximumAnnual: maxCrossBorderAnnualLimit,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: crossBorderLimits.suggestedUpgrade,
            earn: nil
        )
    }
}

extension EffectiveLimit {

    fileprivate init(crossBorderLimits: CrossBorderLimits, maxLimitFallbak: MoneyValue) {
        let periodicLimits: [(limit: PeriodicLimit?, timeFrame: EffectiveLimit.TimeFrame)] = [
            (crossBorderLimits.currentLimits?.daily, .daily),
            (crossBorderLimits.currentLimits?.monthly, .monthly),
            (crossBorderLimits.currentLimits?.yearly, .yearly)
        ]
        let effectiveLimit = periodicLimits.first(where: { $0.limit?.effective == true })
        self.init(
            timeframe: effectiveLimit?.timeFrame ?? .single,
            value: effectiveLimit?.limit?.limit ?? maxLimitFallbak
        )
    }
}
