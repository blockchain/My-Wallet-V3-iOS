//
//  ExchangeService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias CompletionHandler = ((Result<[ExchangeTradeCellModel]>) -> Void)

protocol ExchangeHistoryAPI {
    func getHomebrewTrades(before date: Date, completion: @escaping CompletionHandler)
    func getAllTrades(with completion: @escaping CompletionHandler)
    func isExecuting() -> Bool
}

// TODO: Note this is a WIP. 
class ExchangeService: NSObject {
    
    typealias CompletionHandler = ((Result<[ExchangeTradeCellModel]>) -> Void)

    var tradeModels: [ExchangeTradeCellModel] = []
    fileprivate let partnerAPI: PartnerExchangeAPI = PartnerExchangeService()
    fileprivate let homebrewAPI: HomebrewExchangeAPI = HomebrewExchangeService()
    
    fileprivate var partnerOperation: AsyncBlockOperation!
    fileprivate var homebrewOperation: AsyncBlockOperation!
    fileprivate let tradeQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    fileprivate func sort(models: [ExchangeTradeCellModel]) -> [ExchangeTradeCellModel] {
        let sorted = models.sorted(by: { $0.transactionDate.compare($1.transactionDate) == .orderedDescending })
        return sorted
    }
}

extension ExchangeService: ExchangeHistoryAPI {
    func getHomebrewTrades(before date: Date = Date(), completion: @escaping CompletionHandler) {
        
        if let op = homebrewOperation {
            guard op.isExecuting == false else { return }
        }
        
        var result: Result<[ExchangeTradeCellModel]> = .error(nil)
        homebrewOperation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            this.homebrewAPI.nextPage(fromTimestamp: date, completion: { (models, error) in
                if let err = error {
                    result = .error(err)
                }
                if let result = models {
                    this.tradeModels.append(contentsOf: result)
                }
                complete()
            })
        })
        homebrewOperation.addCompletionBlock { [weak self] in
            guard let this = self else { return }
            if case let .success(value) = result {
                let models = this.sort(models: value)
                completion(.success(models))
            } else {
                completion(result)
            }
        }
        homebrewOperation.start()
    }
    
    func getAllTrades(with completion: @escaping CompletionHandler) {
        /// Trades are being fetched, bail early.
        if let op = homebrewOperation {
            op.cancel()
        }
        guard tradeQueue.operations.count == 0 else { return }
        
        partnerOperation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            this.partnerAPI.fetchTransactions(with: { (models, error) in
                if let result = models {
                    this.tradeModels.append(contentsOf: result)
                }
                complete()
            })
        })
        
        homebrewOperation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            this.homebrewAPI.nextPage(fromTimestamp: Date(), completion: { (models, error) in
                if let result = models {
                    this.tradeModels.append(contentsOf: result)
                }
                complete()
            })
        })
        homebrewOperation.addCompletionBlock { [weak self] in
            guard let this = self else { return }
            this.tradeModels = this.sort(models: this.tradeModels)
            completion(.success(this.tradeModels))
        }
        
        homebrewOperation.addDependency(partnerOperation)
        
        tradeQueue.addOperations([partnerOperation, homebrewOperation], waitUntilFinished: false)
    }
    
    func isExecuting() -> Bool {
        return tradeQueue.operations.count > 0 || homebrewOperation.isExecuting
    }
}
