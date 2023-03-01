// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import FeatureAppDomain
import FeatureDashboardDomain
import Foundation
import MoneyKit
import ToolKit

final class DeFiTotalBalanceService {
    let app: AppProtocol
    let repository: AssetBalanceInfoRepositoryAPI

    init(
        app: AppProtocol,
        repository: AssetBalanceInfoRepositoryAPI
    ) {
        self.app = app
        self.repository = repository
    }

    func fetchTotalBalance() -> StreamOf<BalanceInfo, BalanceInfoError> {
        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .mapError(to: Never.self)
            .receive(on: DispatchQueue.main)
            .flatMap { [repository] fiatCurrency -> StreamOf<BalanceInfo, BalanceInfoError> in
                fetchDeFiBalanceInfo(repository: repository)(fiatCurrency, .now)
                    .zip(fetchDeFiBalanceInfo(repository: repository)(fiatCurrency, .oneDay))
                    .map { currentBalanceResult, previousBalanceResult -> Result<BalanceInfo, BalanceInfoError> in
                        let currentBalance: MoneyValue? = currentBalanceResult.success
                        let previousBalance: MoneyValue? = previousBalanceResult.success
                        guard let currentBalance, let previousBalance else {
                            return .failure(.unableToRetrieve)
                        }
                        return balanceInfoBetween(
                            currentBalance: currentBalance,
                            previousBalance: previousBalance
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

func fetchDeFiBalanceInfo(
    repository: AssetBalanceInfoRepositoryAPI
) -> (FiatCurrency, PriceTime) -> StreamOf<MoneyValue, BalanceInfoError> {
    { fiatCurrency, time -> StreamOf<MoneyValue, BalanceInfoError> in
        repository.cryptoNonCustodial(fiatCurrency: fiatCurrency, time: time)
            .map { nonCustodial -> Result<MoneyValue, BalanceInfoError> in
                guard let nonCustodial = nonCustodial.success else {
                    return .failure(BalanceInfoError.unableToRetrieve)
                }
                let balances = nonCustodial.compactMap(\.fiatBalance?.quote)
                do {
                    let totalBalance: MoneyValue = try balances
                        .reduce(MoneyValue.zero(currency: fiatCurrency), +)
                    return .success(totalBalance)
                } catch {
                    return .failure(BalanceInfoError.unableToRetrieve)
                }
            }
            .eraseToAnyPublisher()
    }
}
