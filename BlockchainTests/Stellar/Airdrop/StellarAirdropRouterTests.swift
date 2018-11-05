//
//  StellarAirdropRouterTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import XCTest
@testable import Blockchain

private class MockRegistrationService: StellarAirdropRegistrationAPI {
    var didCallRegisterExpectation: XCTestExpectation?

    func registerForCampaign(xlmAccount: WalletXlmAccount, nabuUser: NabuUser) -> Single<StellarRegisterCampaignResponse> {
        return Single.create(subscribe: { _ -> Disposable in
            self.didCallRegisterExpectation?.fulfill()
            return Disposables.create()
        })
    }
}

class StellarAirdropRouterTests: XCTestCase {

    private var mockAppSettings: MockBlockchainSettingsApp!
    private var mockRegistration: MockRegistrationService!
    private var mockXlmWallet: MockXlmWallet!
    private var mockDataRepo: MockBlockchainDataRepository!
    private var router: StellarAirdropRouter!

    override func setUp() {
        super.setUp()
        mockAppSettings = MockBlockchainSettingsApp()
        mockRegistration = MockRegistrationService()
        mockDataRepo = MockBlockchainDataRepository()
        mockXlmWallet = MockXlmWallet()
        router = StellarAirdropRouter(
            appSettings: mockAppSettings,
            repository: mockDataRepo,
            walletXlmAccountRepo: WalletXlmAccountRepository(wallet: mockXlmWallet),
            registrationService: mockRegistration
        )
    }

    func testRoutesIfTappedOnDeepLink() {
        mockAppSettings.mockDidTapOnAirdropDeepLink = true
        mockXlmWallet.accounts = [
            WalletXlmAccount(publicKey: "public key", label: "label")
        ]
        mockDataRepo.mockNabuUser = NabuUser(
            personalDetails: nil,
            address: nil,
            mobile: nil,
            status: KYCAccountStatus.none,
            state: NabuUser.UserState.none,
            tags: Tags(sunriver: nil)
        )
        mockRegistration.didCallRegisterExpectation = expectation(
            description: "Expects that registration is attempted through router when user has deeplinked."
        )
        router.routeIfNeeded()
        waitForExpectations(timeout: 0.1)
    }

    func testDoesNotRouteIfDidntTapOnDeepLink() {
        mockAppSettings.mockDidTapOnAirdropDeepLink = false
        let exp = expectation(
            description: "Expects that registration is NOT attempted through router when user has NOT deeplinked."
        )
        exp.isInverted = true
        mockRegistration.didCallRegisterExpectation = exp
        router.routeIfNeeded()
        waitForExpectations(timeout: 0.1)
    }
}
