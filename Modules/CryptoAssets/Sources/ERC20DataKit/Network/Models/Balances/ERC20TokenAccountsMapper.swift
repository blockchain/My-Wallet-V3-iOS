// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ERC20Kit
import MoneyKit
import PlatformKit

/// A mapper for ERC-20 token accounts data model to domain model.
final class ERC20TokenAccountsMapper {

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    // MARK: - Setup

    /// Creates an ERC-20 token accounts mapper.
    ///
    /// - Parameter enabledCurrenciesService: An enabled currencies service.
    init(enabledCurrenciesService: EnabledCurrenciesServiceAPI) {
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    // MARK: - Internal Methods

    /// Maps the given ERC-20 token accounts from the data model to the domain model.
    ///
    /// - Parameter response: An ERC-20 token accounts as a data model.
    ///
    /// - Returns: An ERC-20 token accounts as a domain model.
    func toDomain(response: ERC20TokenAccountsResponse) -> ERC20TokenAccounts {
        response.tokenAccounts
            .reduce(into: [:]) { accounts, item in
                guard let account = create(contract: item.tokenHash, balance: item.balance) else {
                    return
                }
                accounts[account.currency] = account
            }
    }

    /// Maps the given ERC-20 token accounts from the data model to the domain model.
    ///
    /// - Parameter response: An ERC-20 token accounts as a data model.
    ///
    /// - Returns: An ERC-20 token accounts as a domain model.
    func toDomain(response: [EVMBalancesResponse.Balance]) -> ERC20TokenAccounts {
        response
            .reduce(into: [:]) { accounts, item in
                guard let account = create(contract: item.identifier, balance: item.amount) else {
                    return
                }
                accounts[account.currency] = account
            }
    }

    private func create(contract: String, balance: String) -> ERC20TokenAccount? {
        guard let currency = CryptoCurrency(
            erc20Address: contract,
            service: enabledCurrenciesService
        ) else {
            return nil
        }
        guard let balance = CryptoValue.create(
            minor: balance,
            currency: currency
        ) else {
            return nil
        }
        return ERC20TokenAccount(
            balance: balance
        )
    }
}
