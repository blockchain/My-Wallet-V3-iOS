//
//  StellarAccountServiceTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxBlocking
import RxSwift
import XCTest
@testable import Blockchain

fileprivate class MockLedgerService: StellarLedgerAPI {
    var ledger: StellarLedger?

    var current: Observable<StellarLedger> {
        guard let ledger = ledger else {
            return Observable.just(StellarLedger.create())
        }
        return Observable.just(ledger)
    }
}

class StellarAccountServiceTests: XCTestCase {

    private var ledgerService: MockLedgerService!
    private var accountService: StellarAccountService!

    override func setUp() {
        super.setUp()
        ledgerService = MockLedgerService()
        accountService = StellarAccountService(
            configuration: .test,
            ledgerService: ledgerService,
            repository: WalletXlmAccountRepository()
        )
    }

    /// Funding account should fail if amount < 2 * baseReserve
    func testFundAccountFailsForSmallAmount() {
        ledgerService.ledger = StellarLedger.create(baseReserveInStroops: 10000000)
        let exp = expectation(description: "amountTooLow error should be thrown.")
        _ = accountService.fundAccount(
            "account ID",
            amount: 0.01,
            sourceKeyPair: StellarKeyPair(accountId: "account", secret: "secret")
        ).subscribe(onError: { error in
            if let stellarError = error as? StellarServiceError, stellarError == StellarServiceError.amountTooLow {
                exp.fulfill()
            }
            if let stellarError = error as? StellarServiceError, stellarError == StellarServiceError.insufficientFundsForNewAccount {
                exp.fulfill()
            }
        })
        wait(for: [exp], timeout: 0.1)
    }
}

fileprivate extension StellarLedger {
    static func create(baseReserveInStroops: Int? = nil) -> StellarLedger {
        return StellarLedger(
            identifier: "",
            token: "",
            sequence: 0,
            transactionCount: 0,
            operationCount: 0,
            closedAt: Date(),
            totalCoins: "",
            feePool: "",
            baseFeeInStroops: nil,
            baseReserveInStroops: baseReserveInStroops
        )
    }
}
