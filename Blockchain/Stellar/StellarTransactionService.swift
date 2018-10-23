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
    
    typealias TransactionResult = StellarTransactionResponse.Result
    
    fileprivate let configuration: StellarConfiguration
    fileprivate lazy var service: stellarsdk.TransactionsService = {
        configuration.sdk.transactions
    }()
    
    init(configuration: StellarConfiguration = .production) {
        self.configuration = configuration
    }
    
    func send(
        to accountID: StellarTransactionAPI.AccountID,
        amount: Decimal,
        completion: @escaping StellarTransactionAPI.CompletionHandler) {
        
    }
    
    func get(transaction transactionHash: String, completion: @escaping ((Result<StellarTransactionResponse>) -> Void)) {
        service.getTransactionDetails(transactionHash: transactionHash) { response -> Void in
            switch response {
            case .success(let details):
                let code = details.transactionResult.code.rawValue
                let result: TransactionResult = code == 0 ? .success : .error(StellarTransactionError(rawValue: Int(code)) ?? .internalError)
                var memo: String?
                if let detailsMemo = details.memo {
                    if case let .text(value) = detailsMemo {
                        memo = value
                    }
                }
                
                let value = StellarTransactionResponse(
                    identifier: details.id,
                    result: result,
                    transactionHash: details.transactionHash,
                    createdAt: details.createdAt,
                    sourceAccount: details.sourceAccount,
                    feePaid: details.feePaid,
                    memo: memo
                )
                DispatchQueue.main.async {
                    completion(.success(value))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.error(error))
                }
            }
        }
    }
    
}
