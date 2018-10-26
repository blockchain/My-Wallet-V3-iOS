//
//  StellarLedgerService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk
import RxSwift
import RxCocoa

class StellarLedgerService: StellarLedgerAPI {
    var current: Observable<StellarLedger> {
        return fetchLedgerStartingWithCache(
            cachedValue: privateLedger,
            networkValue: fetchLedger()
        )
    }
    var currentLedger: StellarLedger? {
        return privateLedger.value
    }
    fileprivate var privateLedger = BehaviorRelay<StellarLedger?>(value: nil)
    
    lazy var service: LedgersService = {
        configuration.sdk.ledgers
    }()
    
    fileprivate var operation: AsyncBlockOperation?
    fileprivate let configuration: StellarConfiguration
    
    init(configuration: StellarConfiguration = .production) {
        self.configuration = configuration
    }
    
    fileprivate func fetchLedger() -> Single<StellarLedger> {
        let single = Single<StellarLedger>.create { observer -> Disposable in
            self.service.getLedgers(cursor: nil, order: .descending, limit: 1, response: { response in
                switch response {
                case .success(let value):
                    if let input = value.records.first {
                        let ledger = StellarLedger(
                            identifier: input.id,
                            token: input.pagingToken,
                            sequence: Int(input.sequenceNumber),
                            transactionCount: input.transactionCount,
                            operationCount: input.operationCount,
                            closedAt: input.closedAt,
                            totalCoins: input.totalCoins,
                            feePool: input.feePool,
                            baseFeeInStroops: input.baseFeeInStroops,
                            baseReserveInStroops: input.baseReserveInStroops
                        )
                        observer(.success(ledger))
                        self.privateLedger.accept(ledger)
                    } else {
                        observer(.error(NSError() as Error))
                    }
                    
                case .failure(let error):
                    observer(.error(error))
                }
            })
            return Disposables.create()
        }
        return single
    }
    
    private func fetchLedgerStartingWithCache(
        cachedValue: BehaviorRelay<StellarLedger?>,
        networkValue: Single<StellarLedger>
        ) -> Observable<StellarLedger> {
        let networkObservable = networkValue.asObservable()
        guard let cachedValue = cachedValue.value else {
            return networkObservable
        }
        return networkObservable.startWith(cachedValue)
    }
}
