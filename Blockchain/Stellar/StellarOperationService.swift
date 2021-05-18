//
//  StellarHistoryService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxCocoa
import RxSwift
import StellarKit
import stellarsdk
import ToolKit

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
class StellarOperationService: StellarOperationsAPI {
    
    var isExecuting: Bool = false
    
    fileprivate let disposables = CompositeDisposable()
    fileprivate var stream: OperationsStreamItem?
    
    fileprivate let repository: StellarWalletAccountRepositoryAPI
    
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
    
    private var privateReplayedOperations: ReplaySubject<[StellarOperation]> = ReplaySubject<[StellarOperation]>.createUnbounded()

    private let configurationService: StellarConfigurationAPI
    
    private var configuration: Single<StellarConfiguration> {
        configurationService.configuration
    }
    
    var sdk: Single<stellarsdk.StellarSDK> {
        configuration.map { $0.sdk }
    }
    
    var operationsService: Single<stellarsdk.OperationsService> {
        sdk.map { $0.operations }
    }
    
    var transactionsService: Single<stellarsdk.TransactionsService> {
        sdk.map { $0.transactions }
    }
    
    private let bag = DisposeBag()
    
    init(
        configurationService: StellarConfigurationAPI = resolve(),
        repository: StellarWalletAccountRepositoryAPI
    ) {
        self.configurationService = configurationService
        self.repository = repository
    }
    
    // MARK: - Public methods
    
    /// Fetches all `StellarOperations` for a given account.
    /// All the `StellarOperations` will have been fetched when
    /// the `Observable` is `completed`.
    func allOperations(from accountID: String, token: String?) -> Observable<StellarPageReponse<StellarOperation>> {
        let observable = operations(from: accountID, token: token).asObservable().takeWhile { [weak self] output -> Bool in
            if let first = output.items.first?.token {
                self?.stream(cursor: first)
            }
            return output.hasNextPage
        }.flatMap { output -> Observable<StellarPageReponse<StellarOperation>> in
            Observable<StellarPageReponse<StellarOperation>>.just(output).concat(
                self.allOperations(from: accountID, token: output.items.last?.token)
            )
        }
        return observable
    }
    
    func clear() {
        privateReplayedOperations = ReplaySubject<[StellarOperation]>.createUnbounded()
    }
    
    func isStreaming() -> Bool {
        stream != nil
    }
    
    func end() {
        stream?.closeStream()
        stream = nil
    }
    
    private func fetchOperationsStartingFromCache() -> Observable<[StellarOperation]> {
        guard let accountID = repository.defaultAccount?.publicKey else {
            return Observable.just([])
        }
        return all(from: accountID)
    }
    
    private func all(from accountID: String) -> Observable<[StellarOperation]> {
        allOperations(from: accountID, token: nil)
            .map { $0.items }
            .reduce([], accumulator: { $0 + $1 })
    }
    
    private func filter(operations: [OperationResponse]) -> [OperationResponse] {
        operations.filter { $0.operationType == .payment || $0.operationType == .accountCreated }
    }
    
    private func buildOperation(from operationResponse: OperationResponse, transaction: TransactionResponse, accountID: String) -> StellarOperation {
        switch operationResponse.operationType {
        case .accountCreated:
            guard let op = operationResponse as? AccountCreatedOperationResponse else { return .unknown }
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
                fee: op.funder == accountID ? Int(transaction.feeCharged ?? "0") : nil,
                memo: nil
            )
            return .accountCreated(created)
        case .payment:
            guard let op = operationResponse as? PaymentOperationResponse else { return .unknown }
            let payment = StellarOperation.Payment(
                token: op.pagingToken,
                identifier: op.id,
                fromAccount: op.from,
                toAccount: op.to,
                direction: op.from == accountID ? .debit : .credit,
                amount: op.amount,
                transactionHash: op.transactionHash,
                createdAt: op.createdAt,
                fee: op.from == accountID ? Int(transaction.feeCharged ?? "0") : nil,
                memo: nil
            )
            return .payment(payment)
        default:
            return .unknown
        }
    }
    
    private func operations(from accountID: AccountID, token: PageToken?) -> Single<StellarPageReponse<StellarOperation>> {
        fetchOperations(from: accountID, token: token)
            .flatMapLatest { response -> Observable<(OperationResponse, Bool)> in
                Observable<(OperationResponse, Bool)>.from(response.items.map { ($0, response.hasNextPage) })
            }
            .concatMap { value -> Observable<(StellarOperation, Bool)> in
                let (item, hasNextPage) = value
                return self.getTransactionDetails(for: item, accountID: accountID)
                    .map { itemDetails -> (StellarOperation, Bool) in
                        (itemDetails, hasNextPage)
                    }
            }
            .toArray()
            .flatMap(weak: self, { (self, items) -> Single<StellarPageReponse<StellarOperation>> in
                let hasNextPage = items.first?.1 ?? false
                let operations = items.map { $0.0 }
                return Single.just(StellarPageReponse<StellarOperation>(
                    hasNextPage: hasNextPage,
                    items: operations
                ))
            })
    }
    
    private func getTransactionDetails(for operation: OperationResponse, accountID: AccountID, transactionsService: stellarsdk.TransactionsService) -> Observable<StellarOperation> {
        Observable<TransactionResponse>.create { observer -> Disposable in
            transactionsService.getTransactionDetails(transactionHash: operation.transactionHash, response: { response in
                switch response {
                case .success(let payload):
                    observer.onNext(payload)
                    observer.onCompleted()
                case .failure(error: let horizonError):
                    observer.onError(horizonError.toStellarServiceError())
                }
            })
            return Disposables.create()
        }
        .flatMap { [weak self] payload -> Observable<StellarOperation> in
            guard let self = self else { return Observable.empty() }
            return Observable.just(self.buildOperation(from: operation, transaction: payload, accountID: accountID))
        }
    }
    
    private func getTransactionDetails(for operation: OperationResponse, accountID: AccountID) -> Observable<StellarOperation> {
        transactionsService
            .flatMap(weak: self) { (self, transactionsService) -> Single<StellarOperation> in
                self.getTransactionDetails(for: operation, accountID: accountID, transactionsService: transactionsService).asSingle()
            }
            .asObservable()
    }
    
    private func fetchOperations(from accountID: AccountID, token: PageToken?, operationsService: stellarsdk.OperationsService) -> Observable<StellarPageReponse<OperationResponse>> {
        Observable<StellarPageReponse<OperationResponse>>.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            operationsService.getOperations(forAccount: accountID, from: token, order: .descending, limit: 200, response: { response in
                switch response {
                case .success(let payload):
                    let hasNextPage = (payload.hasNextPage() && payload.records.count > 0)

                    let filtered = self.filter(operations: payload.records)
                    let response = StellarPageReponse<OperationResponse>(
                        hasNextPage: hasNextPage,
                        items: filtered
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
    
    private func fetchOperations(from accountID: AccountID, token: PageToken?) -> Observable<StellarPageReponse<OperationResponse>> {
        operationsService
            .flatMap(weak: self) { (self, operationsService) -> Single<StellarPageReponse<OperationResponse>> in
                self.fetchOperations(from: accountID, token: token, operationsService: operationsService).asSingle()
            }
            .asObservable()
    }
    
    private func stream(cursor: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let account = self.repository.defaultAccount else {
                self.privateReplayedOperations.onError(StellarAccountError.noXLMAccount)
                return
            }
            guard self.stream == nil else { return }
            
            let accountID = account.publicKey
            
            self.operationsService
                .subscribe(onSuccess: { [weak self] operationsService in
                    self?.stream = operationsService.stream(
                        for: .operationsForAccount(
                            account: accountID,
                            cursor: cursor
                        )
                    )
                    self?.stream?.onReceive(response: { [weak self] response in
                        guard let this = self else { return }
                        switch response {
                        case .open:
                            break
                        case .response(_, let payload):
                            let filtered = this.filter(operations: [payload])
                            let disposable = Observable.from(filtered)
                                .flatMapLatest { operationResponse -> Observable<StellarOperation> in
                                    this.getTransactionDetails(for: operationResponse, accountID: accountID)
                                }
                                .toArray()
                                .subscribe(onSuccess: { result in
                                    this.privateReplayedOperations.onNext(result)
                                })
                            this.disposables.insertWithDiscardableResult(disposable)
                        case .error(let error):
                            Logger.shared.error(
                                "Horizon Error: \(String(describing: error?.localizedDescription))"
                            )
                        }
                    })
                }, onError: { error in
                    Logger.shared.error(
                        "Error: \(String(describing: error.localizedDescription))"
                    )
                })
                .disposed(by: self.bag)
        }
    }
}
