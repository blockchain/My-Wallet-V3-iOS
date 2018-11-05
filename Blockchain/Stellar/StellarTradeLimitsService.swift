//
//  StellarTradeLimitsService.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

class StellarTradeLimitsService: StellarTradeLimitsAPI {

    private let ledgerService: StellarLedgerAPI
    private let accountsService: StellarAccountAPI

    init(ledgerService: StellarLedgerAPI, accountsService: StellarAccountAPI) {
        self.ledgerService = ledgerService
        self.accountsService = accountsService
    }

    func maxSpendableAmount(for accountId: AccountID) -> Single<Decimal> {
        let ledgerObservable = ledgerService.current.take(1)
        let accountDetailsObservable = accountsService.accountDetails(for: accountId).asObservable()
        let minRequiredObservable = minRequiredRemainingAmount(for: accountId).asObservable()

        return Observable.combineLatest(ledgerObservable, accountDetailsObservable, minRequiredObservable)
            .subscribeOn(MainScheduler.asyncInstance)
            .take(1)
            .asSingle()
            .map { ledger, accountDetails, minRequired -> Decimal in
                let balanceInXlm = accountDetails.assetAccount.balance
                let fees = ledger.baseFeeInXlm ?? 0
                let maxSpendable = balanceInXlm - fees - minRequired
                return maxSpendable > 0 ? maxSpendable : 0
            }
    }

    func minRequiredRemainingAmount(for accountId: AccountID) -> Single<Decimal> {
        let ledgerObservable = ledgerService.current.take(1)
        let accountResponseObservable = accountsService.accountResponse(for: accountId).asObservable()
        return Observable.combineLatest(ledgerObservable, accountResponseObservable)
            .subscribeOn(MainScheduler.asyncInstance)
            .take(1)
            .asSingle()
            .map { ledger, accountResponse -> Decimal in
                return Decimal(2 + accountResponse.subentryCount) * (ledger.baseReserveInXlm ?? 0)
            }
    }

    func isSpendable(amount: Decimal, for accountId: AccountID) -> Single<Bool> {
        return maxSpendableAmount(for: accountId).map { maxSpendableAmount -> Bool in
            return amount <= maxSpendableAmount && amount > 0
        }
    }
}
