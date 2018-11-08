//
//  StellarAccountAPI.swift
//  Blockchain
//
//  Created by AlexM on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk
import RxSwift

protocol StellarAccountAPI {
    
    typealias AccountID = String
    typealias CompletionHandler = ((Result<Bool>) -> Void)
    typealias AccountDetailsCompletion = ((Result<StellarAccount>) -> Void)
    
    var currentAccount: StellarAccount? { get }
    
    func currentStellarAccount(fromCache: Bool) -> Maybe<StellarAccount>
    func accountResponse(for accountID: AccountID) -> Single<AccountResponse>
    func accountDetails(for accountID: AccountID) -> Maybe<StellarAccount>
    func clear()

    /// Funds an account. This operation is typically done when trying to send XLM to an address
    /// that does not yet have a stellar account.
    ///
    /// - Parameters:
    ///   - accountID: the ID of the account to create/fund
    ///   - amount: the amount to fund
    ///   - sourceKeyPair: the key/pair of the fundee
    /// - Returns: a Completable
    func fundAccount(
        _ accountID: AccountID,
        amount: Decimal,
        sourceKeyPair: StellarKeyPair
    ) -> Completable

    // Gets the currentStellarAccount if available.
    func prefetch()

    // Checks if address is valid
    func validate(accountID: AccountID) -> Single<Bool>
}
