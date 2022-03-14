// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import ToolKit

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCurrencies: [CurrencyType] { get }
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    /// This returns the supported currencies that a user can link a bank through a partner, eg Yodlee
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { get }
}

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    // MARK: EnabledCurrenciesServiceAPI

    let allEnabledFiatCurrencies: [FiatCurrency] = [.USD, .EUR, .GBP]

    var bankTransferEligibleFiatCurrencies: [FiatCurrency] {
        [.USD]
    }

    var allEnabledCurrencies: [CurrencyType] {
        defer { allEnabledCurrenciesLock.unlock() }
        allEnabledCurrenciesLock.lock()
        return allEnabledCurrenciesLazy
    }

    var allEnabledCryptoCurrencies: [CryptoCurrency] {
        defer { allEnabledCryptoCurrenciesLock.unlock() }
        allEnabledCryptoCurrenciesLock.lock()
        return allEnabledCryptoCurrenciesLazy
    }

    // MARK: Private Properties

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

    private lazy var allEnabledCryptoCurrenciesLazy: [CryptoCurrency] = (nonCustodialCryptoCurrencies + custodialCurrencies + erc20Currencies)
        .unique
        .sorted()

    private lazy var allEnabledCurrenciesLazy: [CurrencyType] = {
        let crypto: [CurrencyType] = allEnabledCryptoCurrencies
            .map { .crypto($0) }
        let fiat: [CurrencyType] = allEnabledFiatCurrencies
            .map { .fiat($0) }
        return crypto + fiat
    }()

    private let allEnabledCryptoCurrenciesLock = NSLock()
    private let allEnabledCurrenciesLock = NSLock()
    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI
    private let repository: SupportedAssetsRepositoryAPI

    // MARK: Init

    init(
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        repository: SupportedAssetsRepositoryAPI = resolve()
    ) {
        self.internalFeatureFlagService = internalFeatureFlagService
        self.repository = repository
    }
}
