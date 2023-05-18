// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCurrencies: [CurrencyType] { get }
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    var allEnabledEVMNetworks: [EVMNetwork] { get }
    /// This returns the supported currencies that a user can link a bank through a partner, eg Yodlee
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { get }

    /// Retrieves the network based on the given currency
    func network(for cryptoCurrency: CryptoCurrency) -> EVMNetwork?
    /// Retrieves the network based on the given chain id
    func network(for chainId: String) -> EVMNetwork?
}
