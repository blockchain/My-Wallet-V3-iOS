//
//  NabuAuthenticationServiceTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 11/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import XCTest

class NabuAuthenticationServiceTests: XCTestCase {

    func testAuthFailsWhenWalletNotInit() {
        let mockWallet = MockWallet()!
        mockWallet.mockIsInitialized = false

        let exp = expectation(description: "Auth fails when wallet not initialized.")

        let nabuAuthService = NabuAuthenticationService(wallet: mockWallet)
        nabuAuthService.getSessionToken(requestNewToken: true).subscribe(onError: { error in
            if let walletError = error as? WalletError, walletError == WalletError.notInitialized {
                exp.fulfill()
            }
        })

        wait(for: [exp], timeout: 0.1)
    }
}
