// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit

public final class FiatAsset: Asset {

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let factory: FiatCustodialAccountFactoryAPI

    // MARK: - Setup

    public init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        factory: FiatCustodialAccountFactoryAPI = resolve()
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.factory = factory
    }

    // MARK: - Asset

    public func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {
        guard filter.contains(.custodial) else {
            return .just(nil)
        }

        let accounts = enabledCurrenciesService
            .allEnabledFiatCurrencies
            .map { factory.fiatCustodialAccount(fiatCurrency: $0) }
        let group = FiatAccountGroup(accounts: accounts)
        return .just(group)
    }

    public func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        .just(nil)
    }

    public func transactionTargets(
        account: SingleAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], Never> {
        .just([])
    }

    public func transactionTargets(
        account: SingleAccount
    ) -> AnyPublisher<[SingleAccount], Never> {
        .just([])
    }
}
