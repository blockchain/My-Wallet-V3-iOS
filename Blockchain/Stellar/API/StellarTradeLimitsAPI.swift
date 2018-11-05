//
//  StellarTradeLimitsAPI.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol StellarTradeLimitsAPI {

    typealias AccountID = String

    /// The maximum spendable XLM amount for the account with ID `accountId`. This takes
    /// into account the user's balance as well as the minimum balance required for the
    /// account after sending XLM (balance after fees).
    ///
    /// - Parameter accountId: the account ID
    /// - Returns: a Single returning the maximum spendable amount in XLM
    func maxSpendableAmount(for accountId: AccountID) -> Single<Decimal>

    /// The minimum amount required in the user's account.
    ///
    /// - Parameter accountId: the account ID
    /// - Returns: a Single returning the minimum required amount
    func minRequiredRemainingAmount(for accountId: AccountID) -> Single<Decimal>

    /// Returns a Single<Bool> emitting whether or not the amount can be spent. This takes
    /// into account the max spendable amount.
    ///
    /// - Parameters:
    ///   - amount: the amount to send in XLM
    ///   - accountId: the account ID
    /// - Returns: a Single<Bool>
    func isSpendable(amount: Decimal, for accountId: AccountID) -> Single<Bool>
}
