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

protocol StellarOperationServiceDelegate: class {
    func service(_ service: StellarOperationService, recieved operations: [StellarOperation])
    func service(_ service: StellarOperationService, returned error: Error?)
}

class StellarOperationService {
    
    fileprivate var operation: AsyncBlockOperation?
    
    var canPage: Bool = false
    var stream: OperationsStreamItem?
    weak var delegate: StellarOperationServiceDelegate?

    fileprivate let configuration: StellarConfiguration
    fileprivate let repository: WalletXlmAccountRepository
    
    lazy var service: stellarsdk.OperationsService = {
        configuration.sdk.operations
    }()
    
    fileprivate var disposable: Disposable?
    var operations: Observable<[StellarOperation]> {
        return privateOperations.asObservable()
    }
    fileprivate var privateOperations = BehaviorSubject<[StellarOperation]>(value: [])

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
                balance: op.startingBalance,
                token: op.pagingToken,
                sourceAccountID: op.sourceAccount,
                transactionHash: op.transactionHash,
                createdAt: op.createdAt
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
                createdAt: op.createdAt
            )
            return .payment(payment)
        default:
            return .unknown
        }
    }
}

extension StellarOperationService: StellarOperationsAPI {
    func operations(from accountID: StellarOperationsAPI.AccountID, token: PageToken?, completion: @escaping StellarOperationsAPI.Completion) {
        if let op = operation {
            guard op.isExecuting == false else { return }
        }
        
        operation = AsyncBlockOperation(executionBlock: { [weak self] complete in
            guard let this = self else { return }
            
            this.service.getOperations(forAccount: accountID, from: token, order: .descending, limit: 50, response: { response in
                switch response {
                case .success(let payload):
                    this.canPage = payload.hasNextPage()
                    let filtered = this.filter(operations: payload.records)
                    let models = filtered.map {
                        this.buildOperation(from: $0, accountID: accountID)
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success(models))
                    }
                case .failure(error: let horizonError):
                    this.canPage = false
                    DispatchQueue.main.async {
                        completion(.error(horizonError))
                    }
                }
                complete()
            })
        })
        operation?.start()
    }

    func isExecuting() -> Bool {
        guard let op = operation else { return false }
        return op.isExecuting
    }

    func cancel() {
        guard let op = operation else { return }
        op.cancel()
    }
}

extension StellarOperationService: StellarOperationsStreamAPI {
    
    func start() {
        guard let account = repository.defaultAccount else {
            privateOperations.onError(StellarServiceError.noXLMAccount)
            return
        }
        
        let accountID = account.publicKey
        
        operations(from: accountID, token: nil) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let payload):
                guard let latest = payload.first else { return }
                this.privateOperations.onNext(payload)
                this.stream = this.service.stream(
                    for: .operationsForAccount(
                        account: accountID,
                        cursor: latest.token
                    )
                )
                this.stream?.onReceive(response: { response in
                    switch response {
                    case .open:
                        break
                    case .response(_, let payload):
                        let filtered = this.filter(operations: [payload])
                        let result = filtered.map { this.buildOperation(from: $0, accountID: accountID) }
                        this.privateOperations.onNext(result)
                    case .error(let error):
                        Logger.shared.error(
                            "Horizon Error: \(String(describing: error?.localizedDescription))"
                        )
                    }
                })
            case .error(let error):
                Logger.shared.error(
                    "Horizon Error: \(String(describing: error?.localizedDescription))"
                )
                this.privateOperations.onError(error ?? StellarServiceError.unknown)
            }
        }
    }
    
    func end() {
        stream?.closeStream()
        stream = nil
    }
    
}
