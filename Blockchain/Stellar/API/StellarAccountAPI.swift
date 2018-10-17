//
//  StellarAccountAPI.swift
//  Blockchain
//
//  Created by AlexM on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

protocol StellarAccountAPI {
    
    typealias AccountID = String
    typealias CompletionHandler = ((Result<Bool>) -> Void)
    typealias AccountDetailsCompletion = ((Result<StellarAccount>) -> Void)
    
    func accountDetails(for accountID: AccountID, completion: @escaping AccountDetailsCompletion)
    func fundAccount(with accountID: AccountID, amount: Decimal, completion: @escaping CompletionHandler)
}
