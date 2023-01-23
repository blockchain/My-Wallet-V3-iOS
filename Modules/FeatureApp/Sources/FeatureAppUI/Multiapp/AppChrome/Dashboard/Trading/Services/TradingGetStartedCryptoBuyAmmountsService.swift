// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureDashboardDomain
import Foundation
import MoneyKit
import ToolKit

public struct TradingGetStartedAmmountValue: Hashable {
    let valueToDisplay: String
    let valueToPreselectOnBuy: String
}

struct TradingGetStartedCryptoBuyAmmountsService {
    var cryptoBuyAmmounts: @Sendable () async throws -> [TradingGetStartedAmmountValue]
}

extension TradingGetStartedCryptoBuyAmmountsService: DependencyKey {
    static var liveValue: TradingGetStartedCryptoBuyAmmountsService = {
        let app: AppProtocol = DIKit.resolve()
        let live = TradingGetStartedCryptoBuyAmmountsService.Live(
            app: app
        )
        return TradingGetStartedCryptoBuyAmmountsService(
            cryptoBuyAmmounts: {
                try await live.cryptoBuyAmmounts()
            }
        )
    }()
    static var testValue = TradingGetStartedCryptoBuyAmmountsService(cryptoBuyAmmounts: { unimplemented() })
    static var previewValue = TradingGetStartedCryptoBuyAmmountsService(
        cryptoBuyAmmounts: {
            [TradingGetStartedAmmountValue(valueToDisplay: "$100", valueToPreselectOnBuy: "10000")]
        }
    )
}

extension DependencyValues {
    var tradingGetStartedCryptoBuyAmmountsService: TradingGetStartedCryptoBuyAmmountsService {
        get { self[TradingGetStartedCryptoBuyAmmountsService.self] }
        set { self[TradingGetStartedCryptoBuyAmmountsService.self] = newValue }
    }
}

// MARK: - Private

extension TradingGetStartedCryptoBuyAmmountsService {
    struct Live {
        let app: AppProtocol

        init(
            app: AppProtocol
        ) {
            self.app = app
        }

        func cryptoBuyAmmounts() async throws -> [TradingGetStartedAmmountValue] {
            let currency = try? await app.get(blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self)
            guard let currency else {
                return []
            }
            let values: [BigInt] = [100, 200]
            return values.map { value in
                TradingGetStartedAmmountValue(
                    valueToDisplay: FiatValue
                        .create(majorBigInt: value, currency: currency)
                        .toDisplayString(includeSymbol: true, format: .shortened),
                    valueToPreselectOnBuy: "\(value * BigInt(10).power(currency.displayPrecision))"
                )
            }
        }
    }
}
