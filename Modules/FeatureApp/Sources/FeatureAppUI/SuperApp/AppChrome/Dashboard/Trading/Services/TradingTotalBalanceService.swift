// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import FeatureAppDomain
import FeatureDashboardDomain
import Foundation
import MoneyKit
import ToolKit

final class TradingTotalBalanceService {
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
                fetchTradingBalanceInfo(repository: repository)(fiatCurrency, .now)
                    .combineLatest(fetchTradingBalanceInfo(repository: repository)(fiatCurrency, .oneDay))
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
                    .removeDuplicates()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

func fetchTradingBalanceInfo(
    repository: AssetBalanceInfoRepositoryAPI
) -> (FiatCurrency, PriceTime) -> StreamOf<MoneyValue, BalanceInfoError> {
    { fiatCurrency, time -> StreamOf<MoneyValue, BalanceInfoError> in
        repository.cryptoCustodial(fiatCurrency: fiatCurrency, time: time)
            .combineLatest(repository.fiat(fiatCurrency: fiatCurrency, time: time))
            .map { custodialInfo, fiatInfo -> Result<MoneyValue, BalanceInfoError> in
                var total: [MoneyValue] = []
                if let custodial = custodialInfo.success {
                    let allCustodial = custodial.map(\.fiatBalance?.quote).compactMap { $0 }
                    total.append(contentsOf: allCustodial)
                }
                if let fiat = fiatInfo.success {
                    let allFiat = fiat.map(\.fiatBalance?.quote).compactMap { $0 }
                    total.append(contentsOf: allFiat)
                }
                do {
                    let totalBalance: MoneyValue = try total.reduce(MoneyValue.zero(currency: fiatCurrency), +)
                    return .success(totalBalance)
                } catch {
                    return .failure(BalanceInfoError.unableToRetrieve)
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
