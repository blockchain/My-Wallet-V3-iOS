//
//  StellarTransactionServiceAPI.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import stellarsdk

class StellarTransactionServiceAPI: SimpleListServiceAPI {
    
    fileprivate var blockOperation: AsyncBlockOperation?
    
    fileprivate let cache: StellarTransactionCache
    fileprivate let provider: XLMServiceProvider
    fileprivate let operationService: StellarOperationService
    fileprivate let transactionService: StellarTransactionAPI
    fileprivate let disposables = CompositeDisposable()
    fileprivate var operations: [StellarOperation]?
    
    init(provider: XLMServiceProvider = XLMServiceProvider.shared) {
        self.provider = provider
        self.operationService = provider.services.operation
        self.transactionService = provider.services.transaction
        self.cache = StellarTransactionCache()
    }
    
    fileprivate func fetch(with output: SimpleListOutput?) {
        let disposable = operationService.operations
            .map { $0 }
            .scan([], accumulator: {
                return $1 + $0
            })
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.operations = result
                output?.loadedItems(result)
                }, onError: { error in
                    output?.itemFetchFailed(error: error)
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    func fetchAllItems(output: SimpleListOutput?) {
        /// We have to confirm that the user has a `StellarAccount`. If they don't
        /// the actual fetch for the account's operations will fail. In the event of
        /// it failing we will no longer be subscribed to those incoming operations.
        /// Rather than managing state and checking for error types (the error if
        /// an account doesn't exist is `notFound`). It made more sense to do this.
        let disposable = provider.services.accounts.currentStellarAccount(fromCache: false)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { account in
                self.fetch(with: output)
            }, onError: { error in
                // TODO: If there are no transactions, users may want to request XLM
                // like they can on the other screens.
                // Users will never have zero transactions if they have an account as
                // the initial funding of the account counts as a transaction. 
                output?.itemFetchFailed(error: error)
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    func refresh(output: SimpleListOutput?) {
        fetchAllItems(output: output)
    }
    
    func fetchDetails(for item: Identifiable, output: SimpleListOutput?) {
        guard let model = item as? StellarOperation else { return }
        if let cached = cache.itemWithKey(model.transactionHash) {
            output?.showItemDetails(cached)
            return
        }
        output?.willApplyUpdate()
        blockOperation = AsyncBlockOperation(executionBlock: { [weak self] finished in
            guard let this = self else { return }
            this.transactionService.get(transaction: model.transactionHash) { result in
                switch result {
                case .success(let payload):
                    var updated: StellarOperation?
                    if case var .accountCreated(created) = model {
                        created.fee = payload.feePaid
                        created.memo = payload.memo
                        updated = .accountCreated(created)
                    }
                    
                    if case var .payment(payment) = model {
                        payment.fee = payload.feePaid
                        payment.memo = payload.memo
                        updated = .payment(payment)
                    }
                    guard let value = updated else { return }
                    this.cache.save(value, key: value.transactionHash)
                    DispatchQueue.main.async {
                        output?.didApplyUpdate()
                        output?.showItemDetails(value)
                    }
                case .error(let error):
                    DispatchQueue.main.async {
                        output?.didApplyUpdate()
                        output?.itemFetchFailed(error: error)
                    }
                }
                finished()
            }
        })
        
        blockOperation?.start()
    }
    
    func nextPageBefore(identifier: String) {
        // TODO: Not necessary given that we aren't paginating
    }

    func cancel() {
        blockOperation?.cancel()
    }
    
    func isExecuting() -> Bool {
        return blockOperation?.isExecuting ?? false
    }

    func canPage() -> Bool {
        // You should never be able to page when looking at
        // XLM transactions given that we are polling the endpoint
        // and not using traditional pagination.
        return false
    }

    deinit {
        disposables.dispose()
    }
}
