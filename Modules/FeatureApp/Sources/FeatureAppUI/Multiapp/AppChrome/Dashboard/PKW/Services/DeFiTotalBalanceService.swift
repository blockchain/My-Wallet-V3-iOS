// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import FeatureDashboardDomain
import Foundation
import MoneyKit
import ToolKit

public struct DeFiTotalBalanceInfo: Equatable {
    public let balance: MoneyValue

    public var formatted: String {
        balance.toDisplayString(includeSymbol: true)
    }
}

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

    func fetchTotalBalance() -> StreamOf<DeFiTotalBalanceInfo, TotalBalanceServiceError> {
        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .receive(on: DispatchQueue.main)
            .flatMap { [repository] fiatCurrency -> StreamOf<DeFiTotalBalanceInfo, TotalBalanceServiceError> in
                repository.cryptoNonCustodial(fiatCurrency: fiatCurrency, time: .now)
                    .map { custodialInfo -> Result<DeFiTotalBalanceInfo, TotalBalanceServiceError> in
                        guard let custodial = custodialInfo.success else {
                            return .failure(TotalBalanceServiceError.unableToRetrieve)
                        }
                        do {
                            let totalBalance: MoneyValue = try custodial.compactMap { $0.fiatBalance?.quote }
                                .reduce(MoneyValue.zero(currency: fiatCurrency), +)
                            return .success(
                                DeFiTotalBalanceInfo(
                                    balance: totalBalance
                                )
                            )
                        } catch {
                            return .failure(TotalBalanceServiceError.unableToRetrieve)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
