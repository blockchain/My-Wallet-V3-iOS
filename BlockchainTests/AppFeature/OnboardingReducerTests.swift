// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureAuthenticationDomain
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxSwift
import XCTest

@testable import BlockchainApp
@testable import FeatureAppUI
@testable import FeatureAuthenticationMock
@testable import FeatureAuthenticationUI

final class OnboardingReducerTests: XCTestCase {

    var app: AppProtocol!
    var settingsApp: MockBlockchainSettingsApp!
    var mockCredentialsStore: CredentialsStoreAPIMock!
    var mockAlertPresenter: MockAlertViewPresenter!
    var mockDeviceVerificationService: MockDeviceVerificationService!
    var mockWalletPayloadService: MockWalletPayloadService!
    var mockMobileAuthSyncService: MockMobileAuthSyncService!
    var mockPushNotificationsRepository: MockPushNotificationsRepository!
    var mockExternalAppOpener: MockExternalAppOpener!
    var mockForgetWalletService: ForgetWalletService!
    var mockRecaptchaService: MockRecaptchaService!
    var mockQueue: TestSchedulerOf<DispatchQueue>!
    var mockLegacyGuidRepository: MockLegacyGuidRepository!
    var mockLegacySharedKeyRepository: MockLegacySharedKeyRepository!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        app = App.test
        settingsApp = MockBlockchainSettingsApp()
        mockCredentialsStore = CredentialsStoreAPIMock()

        mockDeviceVerificationService = MockDeviceVerificationService()
        mockWalletPayloadService = MockWalletPayloadService()
        mockMobileAuthSyncService = MockMobileAuthSyncService()
        mockPushNotificationsRepository = MockPushNotificationsRepository()
        mockAlertPresenter = MockAlertViewPresenter()
        mockExternalAppOpener = MockExternalAppOpener()
        mockQueue = DispatchQueue.test
        mockForgetWalletService = ForgetWalletService.mock(called: {})
        mockRecaptchaService = MockRecaptchaService()
        mockLegacyGuidRepository = MockLegacyGuidRepository()
        mockLegacySharedKeyRepository = MockLegacySharedKeyRepository()

        // disable the manual login
        app.remoteConfiguration.override(blockchain.app.configuration.manual.login.is.enabled[].reference, with: false)
    }

    var onboardingEnvironment: Onboarding.Environment {
        Onboarding.Environment(
            app: app,
            appSettings: settingsApp,
            credentialsStore: mockCredentialsStore,
            alertPresenter: mockAlertPresenter,
            mainQueue: mockQueue.eraseToAnyScheduler(),
            deviceVerificationService: mockDeviceVerificationService,
            legacyGuidRepository: mockLegacyGuidRepository,
            legacySharedKeyRepository: mockLegacySharedKeyRepository,
            mobileAuthSyncService: mockMobileAuthSyncService,
            pushNotificationsRepository: mockPushNotificationsRepository,
            walletPayloadService: mockWalletPayloadService,
            externalAppOpener: mockExternalAppOpener,
            forgetWalletService: mockForgetWalletService,
            recaptchaService: mockRecaptchaService,
            buildVersionProvider: { "v1.0.0" },
            appUpgradeState: { .just(nil) }
        )
    }

    override func tearDownWithError() throws {
        app = nil
        settingsApp = nil
        mockCredentialsStore = nil
        mockAlertPresenter = nil
        mockDeviceVerificationService = nil
        mockWalletPayloadService = nil
        mockMobileAuthSyncService = nil
        mockPushNotificationsRepository = nil
        mockExternalAppOpener = nil
        mockRecaptchaService = nil
        mockQueue = nil
        mockLegacyGuidRepository = nil
        mockLegacySharedKeyRepository = nil

        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = Onboarding.State()
        XCTAssertNil(state.pinState)
        XCTAssertNil(state.appUpgradeState)
        XCTAssertNil(state.passwordRequiredState)
        XCTAssertNil(state.welcomeState)
        XCTAssertNil(state.displayAlert)
        XCTAssertNil(state.deeplinkContent)
        XCTAssertNil(state.walletCreationContext)
        XCTAssertNil(state.walletRecoveryContext)
    }

    func test_should_authenticate_when_pinIsSet_and_guidSharedKey_are_set() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: onboardingEnvironment
        )

        // given
        mockLegacyGuidRepository.directSet(guid: "a-guid")
        mockLegacySharedKeyRepository.directSet(sharedKey: "a-sharedKey")
        settingsApp.isPinSet = true

        // then
        testStore.send(.start)
        testStore.receive(.proceedToFlow) { state in
            state.pinState = .init()
        }
        testStore.receive(.pin(.authenticate)) { state in
            state.pinState?.authenticate = true
        }
    }

    func test_should_passwordScreen_when_pin_is_not_set() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: onboardingEnvironment
        )

        // given
        mockLegacyGuidRepository.directSet(guid: "a-guid")
        mockLegacySharedKeyRepository.directSet(sharedKey: "a-sharedKey")
        settingsApp.isPinSet = false

        // then
        testStore.send(.start)
        testStore.receive(.proceedToFlow) { state in
            state.passwordRequiredState = .init(
                walletIdentifier: self.mockLegacyGuidRepository.directGuid ?? ""
            )
        }
        testStore.receive(.passwordScreen(.start))
    }

    func test_should_authenticate_pinIsSet_and_icloud_restoration_exists() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: onboardingEnvironment
        )

        // given
        mockLegacyGuidRepository.directSet(guid: "a-guid")
        mockLegacySharedKeyRepository.directSet(sharedKey: "a-sharedKey")
        settingsApp.isPinSet = true

        // then
        testStore.send(.start)
        testStore.receive(.proceedToFlow) { state in
            state.pinState = .init()
        }
        testStore.receive(.pin(.authenticate)) { state in
            state.pinState?.authenticate = true
        }
    }

    func test_should_passwordScreen_whenPin_not_set_and_icloud_restoration_exists() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: onboardingEnvironment
        )

        // given
        mockLegacyGuidRepository.directSet(guid: "a-guid")
        mockLegacySharedKeyRepository.directSet(sharedKey: "a-sharedKey")
        settingsApp.isPinSet = false

        // then
        testStore.send(.start)
        testStore.receive(.proceedToFlow) { state in
            state.passwordRequiredState = .init(
                walletIdentifier: self.mockLegacyGuidRepository.directGuid ?? ""
            )
        }
        testStore.receive(.passwordScreen(.start))
    }

    func test_should_show_welcome_screen() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: onboardingEnvironment
        )

        // given
        mockLegacyGuidRepository.directSet(guid: nil)
        mockLegacySharedKeyRepository.directSet(sharedKey: nil)
        settingsApp.set(pinKey: nil)
        settingsApp.set(encryptedPinPassword: nil)

        // then
        testStore.send(.start)
        testStore.receive(.proceedToFlow) { state in
            state.welcomeState = .init()
        }
        testStore.receive(.welcomeScreen(.start)) { state in
            state.welcomeState?.buildVersion = "v1.0.0"
        }
    }

    func test_forget_wallet_should_show_welcome_screen() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: onboardingEnvironment
        )

        // given
        settingsApp.set(pinKey: "a-pin-key")
        settingsApp.set(encryptedPinPassword: "a-encryptedPinPassword")
        settingsApp.isPinSet = true

        // then
        testStore.send(.start)
        testStore.receive(.proceedToFlow) { state in
            state.pinState = .init()
        }
        testStore.receive(.pin(.authenticate)) { state in
            state.pinState?.authenticate = true
        }

        // when sending forgetWallet as a direct action
        testStore.send(.forgetWallet) { state in
            state.pinState = nil
            state.welcomeState = .init()
        }

        // then
        testStore.receive(.welcomeScreen(.start)) { state in
            state.welcomeState?.buildVersion = "v1.0.0"
        }
    }

    func test_forget_wallet_from_password_screen() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: onboardingEnvironment
        )

        // given
        settingsApp.set(pinKey: "a-pin-key")
        settingsApp.set(encryptedPinPassword: "a-encryptedPinPassword")
        settingsApp.isPinSet = false

        // then
        testStore.send(.start)
        testStore.receive(.proceedToFlow) { state in
            state.passwordRequiredState = .init(
                walletIdentifier: self.mockLegacyGuidRepository.directGuid ?? ""
            )
        }

        testStore.receive(.passwordScreen(.start))
        // when sending forgetWallet from password screen
        testStore.send(.passwordScreen(.forgetWallet)) { state in
            state.passwordRequiredState = nil
            state.welcomeState = .init()
        }
        mockQueue.advance()

        XCTAssertTrue(settingsApp.clearCalled)

        testStore.receive(.welcomeScreen(.start)) { state in
            state.welcomeState?.buildVersion = "v1.0.0"
        }
    }
}
