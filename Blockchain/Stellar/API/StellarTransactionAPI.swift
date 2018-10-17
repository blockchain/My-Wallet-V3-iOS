//
//  StellarTransactionAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol StellarTransactionAPI {
    
    typealias CompletionHandler = ((Result<Bool>) -> Void)
    typealias AccountID = String
    
    func send(to accountID: String, amount: Decimal, completion: @escaping CompletionHandler)
}
