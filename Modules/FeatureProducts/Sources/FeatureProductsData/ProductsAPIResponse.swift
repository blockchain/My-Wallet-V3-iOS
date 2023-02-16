// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProductsDomain

/// A DTO representing multiple products as returned by the BE API.
/// - Note: Needs to be public to be able to make the APIClient interface public.
public struct ProductsAPIResponse: Codable, Hashable {

    public let buy: ProductValue
    public let sell: ProductValue
    public let swap: ProductValue
    public let trade: ProductValue
    public let depositFiat: ProductValue
    public let depositCrypto: ProductValue
    public let depositInterest: ProductValue
    public let depositEarnCC1W: ProductValue
    public let depositStaking: ProductValue
    public let withdrawFiat: ProductValue
    public let withdrawCrypto: ProductValue
    public let useTradingAccount: ProductValue

    var products: [ProductValue] {
        [
            buy,
            sell,
            swap,
            trade,
            depositFiat,
            depositCrypto,
            depositInterest,
            withdrawFiat,
            withdrawCrypto,
            useTradingAccount
        ]
    }
}
