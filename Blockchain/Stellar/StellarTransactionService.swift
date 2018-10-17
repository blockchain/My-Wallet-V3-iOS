//
//  StellarTransactionService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

class StellarTransactionService: StellarTransactionAPI {
    
    fileprivate let configuration: StellarConfiguration
    fileprivate lazy var service: stellarsdk.AccountService = {
        return configuration.sdk.accounts
    }()
    
    init(configuration: StellarConfiguration = .production) {
        self.configuration = configuration
    }
    
    func send(
        to accountID: StellarTransactionAPI.AccountID,
        amount: Decimal,
        completion: @escaping StellarTransactionAPI.CompletionHandler) {
        
    }
    
}
