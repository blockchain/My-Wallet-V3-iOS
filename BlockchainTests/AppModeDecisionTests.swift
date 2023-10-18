@testable import BlockchainApp
import FeatureProductsDomain
import XCTest

class AppModeDecisionTests: XCTestCase {

    func testBothEnabledShouldNotDefaultToDeFi() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: true, defaultProduct: true),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: true, defaultProduct: true),
            isDefaultingEnabled: true,
            hasBeenDefaultedToDefiAlready: false,
            hasBeenDefaultedToTradingAlready: false
        )
        XCTAssertFalse(decision.shouldDefaultToDeFi())
    }

    func testTradingEnabledExternalDisabledShouldNotDefaultToDeFi() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: true, defaultProduct: true),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: false, defaultProduct: false),
            isDefaultingEnabled: true,
            hasBeenDefaultedToDefiAlready: false,
            hasBeenDefaultedToTradingAlready: false
        )
        XCTAssertFalse(decision.shouldDefaultToDeFi())
    }

    func testTradingDisabledExternalEnabledShouldNotDefaultToDeFi() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: false, defaultProduct: false),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: true, defaultProduct: true),
            isDefaultingEnabled: true,
            hasBeenDefaultedToDefiAlready: false,
            hasBeenDefaultedToTradingAlready: false
        )
        XCTAssertFalse(decision.shouldDefaultToDeFi())
    }

    func testBothDisabledShouldDefaultToDeFi() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: false, defaultProduct: false),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: false, defaultProduct: false),
            isDefaultingEnabled: true,
            hasBeenDefaultedToDefiAlready: false,
            hasBeenDefaultedToTradingAlready: false
        )
        XCTAssertTrue(decision.shouldDefaultToDeFi())
    }

    func testTradingDisabledExternalEnabledShouldDefaultToTrading() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: false, defaultProduct: false),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: true, defaultProduct: true),
            isDefaultingEnabled: true,
            hasBeenDefaultedToDefiAlready: false,
            hasBeenDefaultedToTradingAlready: false
        )
        XCTAssertTrue(decision.shouldDefaultToTrading())
    }

    func testTradingEnabledExternalDisabledShouldDefaultToTrading() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: true, defaultProduct: true),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: false, defaultProduct: false),
            isDefaultingEnabled: true,
            hasBeenDefaultedToDefiAlready: false,
            hasBeenDefaultedToTradingAlready: false
        )
        XCTAssertTrue(decision.shouldDefaultToTrading())
    }


    func testTradingDisabledExternalDisabledShouldNotDefaultToTrading() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: false, defaultProduct: false),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: false, defaultProduct: false), 
            isDefaultingEnabled: true,
            hasBeenDefaultedToDefiAlready: false,
            hasBeenDefaultedToTradingAlready: false
        )
        XCTAssertFalse(decision.shouldDefaultToTrading())
    }

    func testTradingEnableddExternalDisabledAlreadyDefaultedShouldNotDefaultToTrading() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: true, defaultProduct: false),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: false, defaultProduct: false),
            isDefaultingEnabled: true,
            hasBeenDefaultedToDefiAlready: false,
            hasBeenDefaultedToTradingAlready: true
        )
        XCTAssertFalse(decision.shouldDefaultToTrading())
    }
}
