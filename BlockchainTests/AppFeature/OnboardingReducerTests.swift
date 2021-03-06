// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import PlatformKit
import PlatformUIKit
import RxSwift
import SettingsKit
import XCTest

@testable import Blockchain

class OnboardingReducerTests: XCTestCase {

    var mockWalletManager: WalletManager!
    var mockWallet: MockWallet = MockWallet()
    var settingsApp: MockBlockchainSettingsApp!
    var mockAlertPresenter: MockAlertViewPresenter!

    override func setUp() {
        settingsApp = MockBlockchainSettingsApp(
            enabledCurrenciesService: MockEnabledCurrenciesService(),
            keychainItemWrapper: MockKeychainItemWrapping(),
            legacyPasswordProvider: MockLegacyPasswordProvider()
        )
        mockWalletManager = WalletManager(
            wallet: mockWallet,
            appSettings: settingsApp,
            reactiveWallet: MockReactiveWallet()
        )
        mockAlertPresenter = MockAlertViewPresenter()
    }

    func test_verify_initial_state_is_correct() {
        let state = Onboarding.State()
        XCTAssertNotNil(state.pinState)
        XCTAssertNil(state.walletUpgradeState)
    }

    func test_should_authenticate_when_pinIsSet_and_guidSharedKey_are_set() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter,
                mainQueue: .main
            )
        )

        // given
        settingsApp.guid = "a-guid"
        settingsApp.sharedKey = "a-sharedKey"
        settingsApp.isPinSet = true

        // then
        testStore.assert(
            .send(.start),
            .receive(.pin(.authenticate), { state in
                state.pinState?.authenticate = true
            })
        )
    }

    func test_should_passwordScreen_when_pin_is_not_set() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter,
                mainQueue: .main
            )
        )

        // given
        settingsApp.guid = "a-guid"
        settingsApp.sharedKey = "a-sharedKey"
        settingsApp.isPinSet = false

        // then
        testStore.assert(
            .send(.start, { state in
                state.passwordScreen = .init()
                state.pinState = nil
                state.walletUpgradeState = nil
            }),
            .receive(.passwordScreen(.start))
        )
    }

    func test_should_authenticate_pinIsSet_and_icloud_restoration_exists() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter,
                mainQueue: .main
            )
        )

        // given
        settingsApp.pinKey = "a-pin-key"
        settingsApp.encryptedPinPassword = "a-encryptedPinPassword"
        settingsApp.isPinSet = true

        // then
        testStore.assert(
            .send(.start),
            .receive(.pin(.authenticate), { state in
                state.pinState?.authenticate = true
            })
        )
    }

    func test_should_passwordScreen_whenPin_not_set_and_icloud_restoration_exists() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter,
                mainQueue: .main
            )
        )

        // given
        settingsApp.pinKey = "a-pin-key"
        settingsApp.encryptedPinPassword = "a-encryptedPinPassword"
        settingsApp.isPinSet = false

        // then
        testStore.assert(
            .send(.start, { state in
                state.passwordScreen = .init()
                state.pinState = nil
                state.walletUpgradeState = nil
            }),
            .receive(.passwordScreen(.start))
        )
    }

    func test_should_show_welcome_screen() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter,
                mainQueue: .main
            )
        )

        // given
        settingsApp.guid = nil
        settingsApp.sharedKey = nil
        settingsApp.pinKey = nil
        settingsApp.encryptedPinPassword = nil

        // then
        testStore.assert(
            .send(.start) { state in
                state.pinState = nil
                state.authenticationState = .init()
            },
            .receive(.welcomeScreen(.start))
        )
    }

    func test_forget_wallet_should_show_welcome_screen() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter,
                mainQueue: .main
            )
        )

        // given
        settingsApp.pinKey = "a-pin-key"
        settingsApp.encryptedPinPassword = "a-encryptedPinPassword"
        settingsApp.isPinSet = true

        // then
        testStore.assert(
            .send(.start),
            .receive(.pin(.authenticate), { state in
                state.pinState?.authenticate = true
            })
        )

        // when sending forgetWallet as a direct action
        testStore.send(.forgetWallet) { state in
            state.pinState = nil
            state.authenticationState = .init()
        }

        // then
        testStore.receive(.welcomeScreen(.start))
    }

    func test_forget_wallet_from_password_screen() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter,
                mainQueue: .main
            )
        )

        // given
        settingsApp.pinKey = "a-pin-key"
        settingsApp.encryptedPinPassword = "a-encryptedPinPassword"
        settingsApp.isPinSet = false

        // then
        testStore.send(.start) { state in
            state.passwordScreen = .init()
            state.pinState = nil
            state.walletUpgradeState = nil
        }

        testStore.receive(.passwordScreen(.start))

        // when sending forgetWallet from password screen
        testStore.send(.passwordScreen(.forgetWallet)) { state in
            state.passwordScreen = nil
            state.authenticationState = .init()
        }

        testStore.receive(.welcomeScreen(.start))
    }
}
