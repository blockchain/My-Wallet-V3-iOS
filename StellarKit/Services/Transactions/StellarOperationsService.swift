//
//  StellarOperationsService.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift
import stellarsdk

public class StellarOperationsService: HistoricalTransactionAPI {
    
    fileprivate let configuration: StellarConfiguration
    lazy var service: stellarsdk.OperationsService = {
        configuration.sdk.operations
    }()
    
    public init(configuration: StellarConfiguration = .production) {
        self.configuration = configuration
    }
    
    public func fetchTransactions(from accountID: AccountID, token: String?, size: Int) -> Observable<PageResult<StellarOperation>> {
        return Observable<PageResult<StellarOperation>>.create { [weak self] observer -> Disposable in
            guard let this = self else { return Disposables.create() }
            
            this.service.getOperations(forAccount: accountID, from: token, order: .descending, limit: 200, response: { response in
                switch response {
                case .success(let payload):
                    let hasNextPage = (payload.hasNextPage() && payload.records.count > 0)
                    
                    let filtered = this.filter(operations: payload.records)
                    let models = filtered.map {
                        this.buildOperation(from: $0, accountID: accountID)
                        }.compactMap { return $0 }
                    
                    let response = PageResult<StellarOperation>(
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
    
    fileprivate func filter(operations: [OperationResponse]) -> [OperationResponse] {
        return operations.filter { $0.operationType == .payment || $0.operationType == .accountCreated }
    }
    
    fileprivate func buildOperation(from response: OperationResponse, accountID: String) -> StellarOperation? {
        switch response.operationType {
        case .accountCreated:
            guard let op = response as? AccountCreatedOperationResponse else { return nil }
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
            guard let op = response as? PaymentOperationResponse else { return nil }
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
            return nil
        }
    }
}
