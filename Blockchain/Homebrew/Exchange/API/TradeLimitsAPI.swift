//
//  TradeLimitsAPI.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Protocol definition for a service that returns the current user's trade limits
protocol TradeLimitsAPI {

    /// Initializes this instance with the provided fiat currency. This should be called
    /// upon starting a new exchange so that trading limits, which is provided in fiat,
    /// can be prefetched.
    ///
    /// - Parameter currency: the current in fiat (e.g. "USD")
    func initialize(withFiatCurrency currency: String)

    /// Returns the trade limits in the provided fiat currency.
    ///
    /// - Parameters:
    ///   - currency: the currency to return the limits in
    ///   - withCompletion: the completion handler invoked when the trading limits are provided.
    func getTradeLimits(withFiatCurrency currency: String, withCompletion: @escaping ((Result<TradeLimits>) -> Void))

    // MARK: - Rx

    /// Rx version of `getTradeLimits(withFiatCurrency: withCompletion:)`
    func getTradeLimits(withFiatCurrency currency: String) -> Single<TradeLimits>
}
