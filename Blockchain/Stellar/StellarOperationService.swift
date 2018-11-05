//
//  StellarHistoryService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk
import RxSwift
import RxCocoa

/// Model for paginating through StellarSDK calls
struct StellarPageReponse<A: Any> {
    let hasNextPage: Bool
    let items: [A]
}

/// The SDK provides a way to stream operations given a user's accountID.
/// That said, you shouldn't use this as a replacement for fetching the operations.
/// You should initially fetch the operations and then begin streaming given the
/// last identifier/cursor of the item that you received.
/// Note that sometimes you will receive an error from the streaming API.
/// Despite receiving an error (on testnet) I still have received operations
/// after the fact.
class StellarOperationService {
    
    var isExecuting: Bool = false
    
    fileprivate let disposables = CompositeDisposable()
    fileprivate var stream: OperationsStreamItem?
    fileprivate let configuration: StellarConfiguration
    fileprivate let repository: WalletXlmAccountRepository
    
    lazy var service: stellarsdk.OperationsService = {
        configuration.sdk.operations
    }()
    
    var operations: Observable<[StellarOperation]> {
        /// We aren't streaming until we have a StellarAccountID.
        /// Each time `operations` is subscribed to, we want to check
        /// if the stream is currently in flight. If it is, we don't
        /// want to restart it as the stream is already publishing to
        /// `privateOperations`
        guard privateReplayedOperations.hasObservers == false else { return privateReplayedOperations.asObserver() }
        
        let disposable = fetchOperationsStartingFromCache()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                self.privateReplayedOperations.onNext(result)
            }, onError: { error in
                self.privateReplayedOperations.onError(error)
            })
        disposables.insertWithDiscardableResult(disposable)
        
        return privateReplayedOperations.asObservable()
    }
    
    fileprivate var privateReplayedOperations: ReplaySubject<[StellarOperation]> = ReplaySubject<[StellarOperation]>.createUnbounded()

    init(
        configuration: StellarConfiguration = .production,
        repository: WalletXlmAccountRepository
    ) {
        self.configuration = configuration
        self.repository = repository
    }
    
    fileprivate func filter(operations: [OperationResponse]) -> [OperationResponse] {
        return operations.filter { $0.operationType == .payment || $0.operationType == .accountCreated }
    }
    
    fileprivate func buildOperation(from response: OperationResponse, accountID: String) -> StellarOperation {
        switch response.operationType {
        case .accountCreated:
            guard let op = response as? AccountCreatedOperationResponse else { return .unknown }
            let created = StellarOperation.AccountCreated(
                identifier: op.id,
                funder: op.funder,
                account: op.account,
                direction: op.funder == accountID ? .debit : .credit,
                balance: op.startingBalance,
                token: op.pagingToken,
                sourceAccountID: op.sourceAccount,
                transactionHash: op.transactionHash,
                createdAt: op.createdAt,
                fee: op.funder == accountID ? 100 : nil,
                memo: nil
            )
            return .accountCreated(created)
        case .payment:
            guard let op = response as? PaymentOperationResponse else { return .unknown }
            let payment = StellarOperation.Payment(
                token: op.pagingToken,
                identifier: op.id,
                fromAccount: op.from,
                toAccount: op.to,
                direction: op.from == accountID ? .debit : .credit,
                amount: op.amount,
                transactionHash: op.transactionHash,
                createdAt: op.createdAt,
                fee: op.from == accountID ? 100 : nil,
                memo: nil
            )
            return .payment(payment)
        default:
            return .unknown
        }
    }
    
    fileprivate func operations(from accountID: AccountID, token: PageToken?) -> Observable<StellarPageReponse<StellarOperation>> {
        return Observable<StellarPageReponse<StellarOperation>>.create { [weak self] observer -> Disposable in
            guard let this = self else { return Disposables.create() }
            
            this.service.getOperations(forAccount: accountID, from: token, order: .descending, limit: 200, response: { response in
                switch response {
                case .success(let payload):
                    let hasNextPage = (payload.hasNextPage() && payload.records.count > 0)
                    
                    let filtered = this.filter(operations: payload.records)
                    let models = filtered.map {
                        this.buildOperation(from: $0, accountID: accountID)
                    }
                    let response = StellarPageReponse<StellarOperation>(
                        hasNextPage: hasNextPage,
                        items: models
                    )
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(error: let horizonError):
                    observer.onError(horizonError.toStellarServiceError())
                }
            })
            return Disposables.create()
        }
    }
    
    // MARK: Public
    
    fileprivate func stream(cursor: String? = nil) {
        guard let account = repository.defaultAccount else {
            privateReplayedOperations.onError(StellarServiceError.noXLMAccount)
            return
        }
        guard stream == nil else { return }
        
        let accountID = account.publicKey
        
        stream = service.stream(
            for: .operationsForAccount(
                account: accountID,
                cursor: cursor
            )
        )
        stream?.onReceive(response: { [weak self] response in
            guard let this = self else { return }
            switch response {
            case .open:
                break
            case .response(_, let payload):
                let filtered = this.filter(operations: [payload])
                let result = filtered.map { this.buildOperation(from: $0, accountID: accountID) }
                this.privateReplayedOperations.onNext(result)
            case .error(let error):
                Logger.shared.error(
                    "Horizon Error: \(String(describing: error?.localizedDescription))"
                )
            }
        })
    }
    
    func isStreaming() -> Bool {
        return stream != nil
    }
    
    func end() {
        stream?.closeStream()
        stream = nil
    }
}

extension StellarOperationService: StellarOperationsAPI {
    
    fileprivate func fetchOperationsStartingFromCache() -> Observable<[StellarOperation]> {
        guard let accountID = repository.defaultAccount?.publicKey else {
            return Observable.just([])
        }
        return all(from: accountID)
    }
    
    fileprivate func all(from accountID: String) -> Observable<[StellarOperation]> {
        return allOperations(from: accountID, token: nil).map {
            $0.items
        }.reduce([], accumulator: { $0 + $1 })
    }

    func clear() {
        privateReplayedOperations = ReplaySubject<[StellarOperation]>.createUnbounded()
    }
    
    /// Fetches all `StellarOperations` for a given account.
    /// All the `StellarOperations` will have been fetched when
    /// the `Observable` is `completed`.
    func allOperations(from accountID: String, token: String?) -> Observable<StellarPageReponse<StellarOperation>> {
        let observable = operations(from: accountID, token: token).takeWhile { [weak self] output -> Bool in
            if let first = output.items.first?.token {
                self?.stream(cursor: first)
            }
            return output.hasNextPage
        }.flatMap { output -> Observable<StellarPageReponse<StellarOperation>> in
            return Observable<StellarPageReponse<StellarOperation>>.just(output).concat(
                self.allOperations(from: accountID, token: output.items.last?.token)
            )
        }
        return observable
    }
}
