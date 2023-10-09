// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxSwift
import XCTest

@testable import BlockchainApp
@testable import FeatureAppUI

class PinReducerTests: XCTestCase {

    var settingsApp: MockBlockchainSettingsApp!

    override func setUp() {
        super.setUp()
        settingsApp = MockBlockchainSettingsApp()
    }

    override func tearDown() {
        settingsApp = nil
        super.tearDown()
    }

    func test_verify_initial_state_is_correct() {
        let state = PinCore.State()
        XCTAssertFalse(state.authenticate)
        XCTAssertFalse(state.creating)
    }

    func test_verify_state_is_changed_correctly_per_action() {
        let testStore = TestStore(
            initialState: PinCore.State(),
            reducer: PinReducer(
                alertPresenter: MockAlertViewPresenter()
            )
        )

        testStore.send(.authenticate) { state in
            state.authenticate = true
            state.creating = false
        }

        testStore.send(.create) { state in
            state.creating = true
            state.authenticate = false
        }
    }
}
