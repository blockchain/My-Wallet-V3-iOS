// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

public final class SelectPaymentMethodService {

    // MARK: - Properties

    /// Streams all the available payment methods, this includes suggested and valid payments
    var methods: Single<[PaymentMethodType]> {
        let methodTypes = paymentMethodTypesService.methodTypes
            .take(1)
            .asSingle()

        return Single
            .zip(
                isUserEligibleForFunds,
                methodTypes,
                fiatCurrencyService.tradingCurrency
                    .asSingle(),
                featureFlagsService
                    .isEnabled(.openBanking)
                    .asSingle()
            )
            .map { payload in
                let (isUserEligibleForFunds, methods, fiatCurrency, isOpenBankingEnabled) = payload
                return methods
                    .filterValidForBuy(
                        currentWalletCurrency: fiatCurrency,
                        accountForEligibility: isUserEligibleForFunds,
                        isOpenBankingEnabled: isOpenBankingEnabled
                    )
            }
    }

    /// Streams the suggested payment methods that a customer can add (credit-card, linked bank, deposit)
    var suggestedMethods: Single<[PaymentMethodType]> {
        methods.map { types -> [PaymentMethodType] in
            types.filter(\.isSuggested)
        }
    }

    /// Streams the available payment methods that a customer can use
    var paymentMethods: Single<[PaymentMethodType]> {
        methods.map { types -> [PaymentMethodType] in
            types.filter { type -> Bool in
                !type.isSuggested
            }
        }
    }

    var isUserEligibleForFunds: Single<Bool> {
        kycTiers.tiers.asSingle().map(\.isVerifiedApproved)
    }

    // MARK: - Injected

    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let kycTiers: KYCTiersServiceAPI
    private let featureFlagsService: FeatureFlagsServiceAPI

    // MARK: - Setup

    public init(
        paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        kycTiers: KYCTiersServiceAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiers = kycTiers
        self.featureFlagsService = featureFlagsService
    }

    func select(method: PaymentMethodType) {
        paymentMethodTypesService.preferredPaymentMethodTypeRelay.accept(method)
    }
}
