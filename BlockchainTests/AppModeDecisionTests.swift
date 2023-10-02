@testable import BlockchainApp
import FeatureProductsDomain
import XCTest

class AppModeDecisionTests: XCTestCase {

    func testBothEnabledShouldNotDefaultToDeFi() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: true, defaultProduct: true),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: true, defaultProduct: true),
            isDefaultingEnabled: true,
            hasBeenDefaultedAlready: false
        )
        XCTAssertFalse(decision.shouldDefaultToDeFi())
    }

    func testTradingEnabledExternalDisabledShouldNotDefaultToDeFi() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: true, defaultProduct: true),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: false, defaultProduct: false),
            isDefaultingEnabled: true,
            hasBeenDefaultedAlready: false
        )
        XCTAssertFalse(decision.shouldDefaultToDeFi())
    }

    func testTradingDisabledExternalEnabledShouldNotDefaultToDeFi() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: false, defaultProduct: false),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: true, defaultProduct: true),
            isDefaultingEnabled: true,
            hasBeenDefaultedAlready: false
        )
        XCTAssertFalse(decision.shouldDefaultToDeFi())
    }

    func testBothDisabledShouldDefaultToDeFi() {
        let decision = AppModeDecision(
            useTradingAccount: ProductValue(id: .useTradingAccount, enabled: false, defaultProduct: false),
            useExternalTradingAccount: ProductValue(id: .useExternalTradingAccount, enabled: false, defaultProduct: false),
            isDefaultingEnabled: true,
            hasBeenDefaultedAlready: false
        )
        XCTAssertTrue(decision.shouldDefaultToDeFi())
    }
}
