//
//  ExchangeService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum ListPresentationUpdate<T: Equatable> {
    typealias Deleted = IndexPath
    typealias Inserted = IndexPath

    case insert(IndexPath, T)
    case delete(IndexPath)
    case move(Deleted, Inserted, T)
    case update(IndexPath, T)
}

protocol ExchangeServiceDelegate: class {
    func exchangeServiceDidBeginUpdates(_ service: ExchangeService)
    func exchangeServiceDidEndUpdates(_ service: ExchangeService)
    func exchangeService(_ service: ExchangeService, didUpdate: [ListPresentationUpdate<ExchangeTradeCellModel>])
    func exchangeService(_ service: ExchangeService, didReturn error: Error)
}

// TODO: Note this is a WIP. 
class ExchangeService: NSObject {

    weak var delegate: ExchangeServiceDelegate?

    fileprivate var tradeModels: Set<ExchangeTradeCellModel> = []
    fileprivate let partnerAPI: PartnerExchangeAPI
    fileprivate let homebrewAPI: HomebrewExchangeAPI
    
    fileprivate var partnerOperation: AsyncBlockOperation!
    fileprivate var homebrewOperation: AsyncBlockOperation!
    fileprivate let tradeQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    override init() {
        partnerAPI = PartnerExchangeService()
        homebrewAPI = HomebrewExchangeService()
        super.init()
    }
    
    func getPartnerTrades() {
        delegate?.exchangeServiceDidBeginUpdates(self)
        
        if let op = partnerOperation {
            guard op.isExecuting == false else { return }
        }
        partnerOperation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            this.partnerAPI.fetchTransactions(with: { (models, error) in
                if let result = models {
                    this.differentiateAndAppend(result)
                }
                complete()
            })
        })
        partnerOperation.addCompletionBlock { [weak self] in
            guard let this = self else { return }
            this.sortAndUpdateTradeModels()
            this.delegate?.exchangeServiceDidEndUpdates(this)
        }
        partnerOperation.start()
    }
    
    func getHomebrewTrades(before date: Date = Date()) {
        delegate?.exchangeServiceDidBeginUpdates(self)
        
        if let op = homebrewOperation {
            guard op.isExecuting == false else { return }
        }
        
        homebrewOperation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            this.homebrewAPI.nextPage(fromTimestamp: date, completion: { (models, error) in
                if let result = models {
                    this.differentiateAndAppend(result)
                }
                complete()
            })
        })
        homebrewOperation.addCompletionBlock { [weak self] in
            guard let this = self else { return }
            this.sortAndUpdateTradeModels()
            this.delegate?.exchangeServiceDidEndUpdates(this)
        }
        homebrewOperation.start()
    }
    
    func getAllTrades() {
        /// Trades are being fetched, bail early.
        guard tradeQueue.operations.count == 0 else { return }
        delegate?.exchangeServiceDidBeginUpdates(self)
        
        partnerOperation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            this.partnerAPI.fetchTransactions(with: { (models, error) in
                if let result = models {
                    this.differentiateAndAppend(result)
                }
                complete()
            })
        })
        
        homebrewOperation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            this.homebrewAPI.nextPage(fromTimestamp: Date(), completion: { (models, error) in
                if let result = models {
                    this.differentiateAndAppend(result)
                }
                complete()
            })
        })
        homebrewOperation.addCompletionBlock { [weak self] in
            guard let this = self else { return }
            this.sortAndUpdateTradeModels()
            this.delegate?.exchangeServiceDidEndUpdates(this)
        }
        
    }

    fileprivate func differentiateAndAppend(_ models: [ExchangeTradeCellModel]) {
        if tradeModels.filter({ models.contains($0) }).count > 0 {
            models.forEach { [weak self] (model) in
                guard let this = self else { return }
                this.tradeModels.insert(model)
            }
        }
    }
    
    fileprivate func sortAndUpdateTradeModels() {
        let sorted = tradeModels.sorted(by: { $0.transactionDate.compare($1.transactionDate) == .orderedDescending })
        let insertions: [ListPresentationUpdate<ExchangeTradeCellModel>] = sorted
            .enumerated()
            .map { (index, model) -> ListPresentationUpdate<ExchangeTradeCellModel> in
            let path = IndexPath(row: index, section: 0)
            return .insert(path, model)
        }
        delegate?.exchangeService(self, didUpdate: insertions)
    }

}
