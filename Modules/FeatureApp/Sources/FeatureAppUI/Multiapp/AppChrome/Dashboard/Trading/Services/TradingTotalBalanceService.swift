// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import FeatureDashboardDomain
import Foundation
import MoneyKit
import ToolKit

public enum TotalBalanceServiceError: LocalizedError {
    case unableToRetrieve
}

public struct TradingTotalBalanceInfo: Codable, Equatable {
    public let balance: MoneyValue

    /// A percentage change of currenct and previou balance, ranges from 0...1
    public let changePercentage: Decimal?
    ///
    public let change: MoneyValue?

    enum Key: CodingKey {
        case balance
        case changePercentage
        case change
    }

    public init(
        balance: MoneyValue,
        changePercentage: Decimal? = nil,
        change: MoneyValue? = nil
    ) {
        self.balance = balance
        self.changePercentage = changePercentage
        self.change = change
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        balance = try container.decode(MoneyValue.self, forKey: .balance)
        let value = try container.decodeIfPresent(String.self, forKey: .changePercentage)
        changePercentage = value != nil ? Decimal(string: value!) : Decimal()
        change = try container.decodeIfPresent(MoneyValue.self, forKey: .change)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(balance, forKey: .balance)
        let value = String(describing: changePercentage)
        try container.encodeIfPresent(value, forKey: .changePercentage)
        try container.encodeIfPresent(change, forKey: .change)
    }
}

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

    func fetchTotalBalance() -> StreamOf<TradingTotalBalanceInfo, TotalBalanceServiceError> {
        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .mapError(to: TotalBalanceServiceError.self)
            .receive(on: DispatchQueue.main)
            .flatMap { [repository] fiatCurrency -> StreamOf<TradingTotalBalanceInfo, TotalBalanceServiceError> in
                fetchTradingBalanceInfo(repository: repository)(fiatCurrency, .now)
                    .zip(fetchTradingBalanceInfo(repository: repository)(fiatCurrency, .oneDay))
                    .map { currentBalanceResult, previousBalanceResult -> Result<TradingTotalBalanceInfo, TotalBalanceServiceError> in
                        let currentBalance: MoneyValue? = currentBalanceResult.success
                        let previousBalance: MoneyValue? = previousBalanceResult.success
                        guard let currentBalance, let previousBalance else {
                            return .failure(.unableToRetrieve)
                        }
                        do {
                            let percentage: Decimal
                            let change = try currentBalance - previousBalance
                            if currentBalance.isZero {
                                percentage = 0
                            } else {
                                if previousBalance.isZero || previousBalance.isNegative {
                                    percentage = 0
                                } else {
                                    percentage = try change.percentage(in: previousBalance)
                                }
                            }
                            let info = TradingTotalBalanceInfo(
                                balance: currentBalance,
                                changePercentage: percentage,
                                change: change
                            )
                            return .success(info)
                        } catch {
                            return .failure(.unableToRetrieve)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .ignoreFailure()
            .eraseToAnyPublisher()
    }
}

func fetchTradingBalanceInfo(
    repository: AssetBalanceInfoRepositoryAPI
) -> (FiatCurrency, PriceTime) -> StreamOf<MoneyValue, TotalBalanceServiceError> {
    { fiatCurrency, time -> StreamOf<MoneyValue, TotalBalanceServiceError> in
        repository.cryptoCustodial(fiatCurrency: fiatCurrency, time: time)
            .zip(repository.fiat(fiatCurrency: fiatCurrency, time: time))
            .map { custodialInfo, fiatInfo -> Result<MoneyValue, TotalBalanceServiceError> in
                var total: [AssetBalanceInfo] = []
                if let custodial = custodialInfo.success {
                    total.append(contentsOf: custodial)
                }
                if let fiat = fiatInfo.success {
                    total.append(contentsOf: fiat)
                }
                do {
                    let totalBalance: MoneyValue = try total.compactMap { $0.fiatBalance?.quote }
                        .reduce(MoneyValue.zero(currency: fiatCurrency), +)
                    return .success(totalBalance)
                } catch {
                    return .failure(TotalBalanceServiceError.unableToRetrieve)
                }
            }
            .eraseToAnyPublisher()
    }
}
