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
    func fundAccount(with accountID: AccountID, amount: Decimal, completion: @escaping CompletionHandler)
}
