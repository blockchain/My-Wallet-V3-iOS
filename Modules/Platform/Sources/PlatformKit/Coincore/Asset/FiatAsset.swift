// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import ToolKit

final class FiatAsset: Asset {

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    // MARK: - Setup

    init(enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) {
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    // MARK: - Asset

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {
        if filter.contains(.custodial) {
            return custodialGroup
        }
        return .just(nil)
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        .just(nil)
    }

    // MARK: - Helpers

    private var allAccountsGroup: AnyPublisher<AccountGroup?, Never> {
        custodialGroup
    }

    private var custodialGroup: AnyPublisher<AccountGroup?, Never> {
        let accounts = enabledCurrenciesService
            .allEnabledFiatCurrencies
            .map { FiatCustodialAccount(fiatCurrency: $0) }
        return .just(FiatAccountGroup(accounts: accounts))
    }

    /// We cannot transfer for fiat
    func transactionTargets(account: SingleAccount, action: AssetAction) -> AnyPublisher<[SingleAccount], Never> {
        .just([])
    }

    func transactionTargets(
        account: SingleAccount
    ) -> AnyPublisher<[SingleAccount], Never> {
        .just([])
    }
}
