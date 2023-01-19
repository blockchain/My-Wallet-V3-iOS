// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit

public typealias CustodialAccountBalanceState = AccountBalanceState<CustodialAccountBalance>

public struct CustodialAccountBalanceStates: Equatable {

    // MARK: - Properties

    static var absent: CustodialAccountBalanceStates {
        CustodialAccountBalanceStates()
    }

    var balances: [CurrencyType: CustodialAccountBalanceState] = [:]
    public var enumeratedBalances: [CustodialAccountBalanceState] {
        Array(balances.values)
    }

    // MARK: - Subscript

    public subscript(currency: CurrencyType) -> CustodialAccountBalanceState {
        get { balances[currency] ?? .absent }
        set { balances[currency] = newValue }
    }

    // MARK: - Init

    public init(balances: [CurrencyType: CustodialAccountBalanceState] = [:]) {
        self.balances = balances
    }
}

extension CustodialAccountBalanceStates {

    // MARK: - Init

    init(
        response: CustodialBalanceResponse,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.balances = response.balances
            .compactMap { item in
                CustodialAccountBalance(
                    currencyCode: item.key,
                    balance: item.value,
                    enabledCurrenciesService: enabledCurrenciesService
                )
            }
            .reduce(into: [CurrencyType: CustodialAccountBalanceState]()) { result, balance in
                result[balance.currency] = .present(balance)
            }
    }
}

extension CustodialAccountBalance {

    // MARK: - Init

    fileprivate init?(
        currencyCode: String,
        balance: CustodialBalanceResponse.Balance,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        guard let currencyType = try? CurrencyType(
            code: currencyCode,
            enabledCurrenciesService: enabledCurrenciesService
        ) else {
            return nil
        }
        self.init(currency: currencyType, response: balance)
    }
}
