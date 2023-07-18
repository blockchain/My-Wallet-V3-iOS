// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Collections
import Combine
import DIKit
import FeatureStakingDomain
import Foundation
import MoneyKit

public protocol EarnDashboardSectionServiceAPI {
    func hasEarnRewards() -> AnyPublisher<Bool, Never>
}

final class EarnDashboardSectionService: EarnDashboardSectionServiceAPI {
    let app: AppProtocol

    init(app: AppProtocol = DIKit.resolve()) {
        self.app = app
    }

    func hasEarnRewards() -> AnyPublisher<Bool, Never> {
        let productsPublisher = app.publisher(for: blockchain.ux.earn.supported.products, as: OrderedSet<EarnProduct>.self)
            .compactMap(\.value)

        return productsPublisher
            .flatMap { [app] products -> AnyPublisher<Bool, Never> in
                products.map { product -> AnyPublisher<Bool, Never> in
                    app.publisher(for: blockchain.user.earn.product[product.value].all.assets, as: [CryptoCurrency].self)
                        .replaceError(with: [])
                        .flatMap { assets -> AnyPublisher<Bool, Never> in
                            assets.map { asset -> AnyPublisher<Bool, Never> in
                                assetHasBalance(app: app, asset: asset, product: product)
                            }
                            .combineLatest()
                            .map { balances in balances.contains(true) }
                            .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                .combineLatest()
                .map { balances in balances.contains(true) }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

func assetHasBalance(app: AppProtocol, asset: CryptoCurrency, product: EarnProduct) -> AnyPublisher<Bool, Never> {
    app.publisher(for: blockchain.user.earn.product[product.value].asset[asset.code].account.balance, as: MoneyValue.self)
        .compactMap(\.value)
        .combineLatest(
            app.publisher(
                for: blockchain.api.nabu.gateway.price.crypto[asset.code].fiat.quote.value,
                as: MoneyValue.self
            )
            .compactMap(\.value)
        )
        .map { balance, quote -> Bool in
            do {
                return try balance.convert(
                    using: MoneyValuePair(
                        base: .one(currency: balance.currency),
                        quote: quote
                    )
                ).isDust == false
            } catch {
                return false
            }
        }
        .replaceError(with: false)
        .eraseToAnyPublisher()
}
