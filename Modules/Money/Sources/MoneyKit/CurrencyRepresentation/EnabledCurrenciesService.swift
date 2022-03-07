// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCurrencies: [CurrencyType] { get }
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    /// This returns the supported currencies that a user can link a bank through a partner, eg Yodlee
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { get }
}

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    private var nonCustodialCryptoCurrencies: [CryptoCurrency] {
        [
            .bitcoin,
            .ethereum,
            .bitcoinCash,
            .stellar
        ]
    }

    private var custodialCurrencies: [CryptoCurrency] {
        repository.custodialAssets
            .currencies
            .filter(\.products.enablesCurrency)
            .filter { !NonCustodialCoinCode.allCases.map(\.rawValue).contains($0.code) }
            .compactMap(\.cryptoCurrency)
    }

    private var erc20Currencies: [CryptoCurrency] {
        repository.erc20Assets
            .currencies
            .filter { !NonCustodialCoinCode.allCases.map(\.rawValue).contains($0.code) }
            .filter(\.kind.isERC20)
            .compactMap(\.cryptoCurrency)
    }

    lazy var allEnabledCryptoCurrencies: [CryptoCurrency] = {
        (nonCustodialCryptoCurrencies + custodialCurrencies + erc20Currencies)
            .unique
            .sorted()
    }()

    lazy var allEnabledCurrencies: [CurrencyType] = {
        let crypto: [CurrencyType] = allEnabledCryptoCurrencies
            .map { .crypto($0) }
        let fiat: [CurrencyType] = allEnabledFiatCurrencies
            .map { .fiat($0) }
        return crypto + fiat
    }()

    let allEnabledFiatCurrencies: [FiatCurrency] = [.USD, .EUR, .GBP]

    var bankTransferEligibleFiatCurrencies: [FiatCurrency] {
        [.USD]
    }

    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI
    private let repository: SupportedAssetsRepositoryAPI

    init(
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        repository: SupportedAssetsRepositoryAPI = resolve()
    ) {
        self.internalFeatureFlagService = internalFeatureFlagService
        self.repository = repository
    }
}
