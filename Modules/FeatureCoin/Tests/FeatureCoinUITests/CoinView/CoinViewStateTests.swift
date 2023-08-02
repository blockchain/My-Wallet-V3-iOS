//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import AnalyticsKit
import BlockchainNamespace
import FeatureCoinDomain
@testable import FeatureCoinUI
import XCTest
import MoneyKit

final class CoinViewStateTests: XCTestCase {
    var app: App.Test!
    var state: CoinViewState!
    override func setUp() {
        super.setUp()
        app = App.test
        state = CoinViewState(currency: .ethereum)
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Primary Actions
    func test_primary_defi_actions_no_balance()  {
        // No Balance, Can Swap
        state = CoinViewState(currency: .ethereum,
                              accounts: [
                                .preview.privateKeyNoBalance
        ],
        isDexEnabled: true)
        state.appMode = .pkw
        XCTAssertEqual(state.primaryActions, [ButtonAction.getToken(currency: CryptoCurrency.ethereum.code)])
    }

    func test_primary_defi_actions_balance_swap()  {
        //Balance, Can Swap, Can't Sell
        state = CoinViewState(currency: .ethereum,
                              kycStatus: .gold,
                              accounts: [
                                Account.Snapshot.stub(
                                    id: "PrivateKey",
                                    name: "DeFi Wallet",
                                    accountType: .privateKey,
                                    actions: [.send, .receive, .activity, .swap]
                                )
        ],
        isDexEnabled: true)
        state.appMode = .pkw
        XCTAssertEqual(state.primaryActions, [ButtonAction.swap()])
    }

    func test_primary_defi_actions_balance_swap_sell()  {
        //Balance, Can Swap, Can Sell
        state = CoinViewState(currency: .ethereum,
                              kycStatus: .gold,
                              accounts: [
                                Account.Snapshot.stub(
                                    id: "PrivateKey",
                                    name: "DeFi Wallet",
                                    accountType: .privateKey,
                                    actions: [.send, .receive, .activity, .swap, .sell]
                                )
        ],
        isDexEnabled: true)
        state.appMode = .pkw
        XCTAssertEqual(state.primaryActions, [ButtonAction.swap(), ButtonAction.sell()])
    }

    func test_primary_defi_actions_balance_sell()  {
        //Balance, Can Swap, Can Sell
        state = CoinViewState(currency: .ethereum,
                              kycStatus: .gold,
                              accounts: [
                                Account.Snapshot.stub(
                                    id: "PrivateKey",
                                    name: "DeFi Wallet",
                                    accountType: .privateKey,
                                    actions: [.send, .receive, .activity, .sell]
                                )
        ],
        isDexEnabled: true)
        state.appMode = .pkw
        XCTAssertEqual(state.primaryActions, [ButtonAction.sell()])
    }

    func test_primary_trading_actions_no_balance()  {
        //No balance
        state = CoinViewState(currency: .ethereum,
                              kycStatus: .gold,
                              accounts: [
                                .preview.tradingNoBalance
        ],
        isDexEnabled: true)
        state.appMode = .trading
        XCTAssertEqual(state.primaryActions, [
            ButtonAction.receive(),
            ButtonAction.buy()
           ]
        )
    }

    func test_primary_trading_actions_balance()  {
        //Balance
        state = CoinViewState(currency: .ethereum,
                              kycStatus: .gold,
                              accounts: [
                                .preview.trading
        ],
        isDexEnabled: true)
        state.appMode = .trading
        XCTAssertEqual(state.primaryActions, [
            ButtonAction.sell(),
            ButtonAction.buy()
           ]
        )
    }

    func test_primary_trading_actions_balance_kyc_unverified()  {
        //Balance, KYC Not Verified
        state = CoinViewState(currency: .ethereum,
                              kycStatus: .unverified,
                              accounts: [
                                .preview.trading
        ],
        isDexEnabled: true)
        state.appMode = .trading
        XCTAssertEqual(state.primaryActions, [
            ButtonAction.receive(),
            ButtonAction.buy()
           ]
        )
    }

    // MARK: - All Actions
    func test_all_trading_actions_kyc_verified() {
        // Balance, KYC verified
        let receive = ButtonAction.receive()
        let send = ButtonAction.send()
        let swap = ButtonAction.swap()
        state = CoinViewState(currency: .ethereum,
                              kycStatus: .gold,
                              accounts: [
                                .preview.trading
        ],
        isDexEnabled: true)
        state.appMode = .trading
        XCTAssertEqual(state.allActions,[swap, receive, send])

    }


    func test_all_trading_actions_kyc_unverified() {
        // Balance, KYC Not Verified
        state = CoinViewState(currency: .ethereum,
                              kycStatus: .unverified,
                              accounts: [
                                .preview.trading
        ],
        isDexEnabled: true)
        state.appMode = .trading
        XCTAssertEqual(state.allActions,[])
    }

    func test_all_trading_actions_no_balance_kyc_verified() {
        // No Balance, KYC verified
        state = CoinViewState(currency: .ethereum,
                              kycStatus: .gold,
                              accounts: [
                                .preview.tradingNoBalance
        ],
        isDexEnabled: true)
        state.appMode = .trading
        XCTAssertEqual(state.allActions,[])

    }

    func test_all_defi_actions_kyc_verified() {
        // Balance, KYC Verified
        let send = ButtonAction.send()
        let receive = ButtonAction.receive()

        state = CoinViewState(currency: .ethereum,
                              kycStatus: .gold,
                              accounts: [
                                .preview.privateKey
        ],
        isDexEnabled: true)
        state.appMode = .pkw
        XCTAssertEqual(state.allActions, [send, receive])

    }

    func test_all_defi_actions_no_balance_kyc_verified() {
        // Balance, KYC Verified
        let send = ButtonAction.send()
        let receive = ButtonAction.receive()

        state = CoinViewState(currency: .ethereum,
                              kycStatus: .gold,
                              accounts: [
                                .preview.privateKeyNoBalance
        ],
        isDexEnabled: true)
        state.appMode = .pkw
        XCTAssertEqual(state.allActions, [send, receive])

    }


    func test_all_defi_actions_kyc_unverified() {
        // Balance, KYC Not Verified
        let send = ButtonAction.send()
        let receive = ButtonAction.receive()

        state = CoinViewState(currency: .ethereum,
                              kycStatus: .unverified,
                              accounts: [
                                .preview.privateKey
        ],
        isDexEnabled: true)
        state.appMode = .pkw
        XCTAssertEqual(state.allActions, [send, receive])

    }

}

