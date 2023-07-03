// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationUI
@testable import ToolKit
import XCTest

// Mocks
@testable import AnalyticsKitMock
@testable import FeatureAuthenticationMock
@testable import ToolKitMock

final class WelcomeReducerTests: XCTestCase {

    private var app: AppProtocol!
    private var dummyUserDefaults: UserDefaults!
    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        WelcomeState,
        WelcomeAction,
        WelcomeState,
        WelcomeAction,
        WelcomeEnvironment
    >!
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = App.test
        mockMainQueue = DispatchQueue.test
        dummyUserDefaults = UserDefaults(suiteName: "welcome.reducer.tests.defaults")!
        app.remoteConfiguration.override(blockchain.app.configuration.manual.login.is.enabled[].reference, with: true)
        testStore = TestStore(
            initialState: .init(),
            reducer: welcomeReducer,
            environment: WelcomeEnvironment(
                app: app,
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                passwordValidator: PasswordValidator(),
                sessionTokenService: MockSessionTokenService(),
                deviceVerificationService: MockDeviceVerificationService(),
                recaptchaService: MockRecaptchaService(),
                buildVersionProvider: { "Test Version" },
                errorRecorder: MockErrorRecorder(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .mock(),
                walletFetcherService: WalletFetcherServiceMock().mock(),
                signUpCountriesService: MockSignUpCountriesService(),
                accountRecoveryService: MockAccountRecoveryService(),
                checkReferralClient: MockCheckReferralClient()
            )
        )
    }

    override func tearDownWithError() throws {
        BuildFlag.isInternal = false
        mockMainQueue = nil
        testStore = nil
        dummyUserDefaults.removeSuite(named: "welcome.reducer.tests.defaults")
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = WelcomeState()
        XCTAssertNil(state.emailLoginState)
    }

    func test_start_shows_manual_pairing_when_feature_flag_is_not_enabled_and_build_is_internal() {
        BuildFlag.isInternal = true
        app.remoteConfiguration.override(blockchain.app.configuration.manual.login.is.enabled[].reference, with: true)
        testStore.send(.start) { state in
            state.buildVersion = "Test Version"
        }
        testStore.receive(.setManualPairingEnabled) { state in
            state.manualPairingEnabled = true
        }
    }

    func test_start_does_not_shows_manual_pairing_when_feature_flag_is_not_enabled_and_build_is_not_internal() {
        BuildFlag.isInternal = false
        app.remoteConfiguration.override(blockchain.app.configuration.manual.login.is.enabled[].reference, with: true)
        testStore.send(.start) { state in
            state.buildVersion = "Test Version"
            state.manualPairingEnabled = false
        }
    }

    func test_enter_into_should_update_welcome_route() {
        let routes: [WelcomeRoute] = [
            .createWallet,
            .emailLogin,
            .restoreWallet,
            .manualLogin
        ]
        routes.forEach { routeValue in
            testStore.send(.navigate(to: routeValue)) { state in
                switch routeValue {
                case .createWallet:
                    state.createWalletState = .init(context: .createWallet)
                case .emailLogin:
                    state.emailLoginState = .init()
                case .restoreWallet:
                    state.restoreWalletState = .init(context: .restoreWallet)
                case .manualLogin:
                    state.manualCredentialsState = .init()
                }
                state.route = RouteIntent(route: routeValue, action: .navigateTo)
            }
        }
    }
    // TODO: enable tests when "resolve()" in credentials reducer are removed
//    func test_second_password_can_be_navigated_to_from_manual_login() {
//        // given (we're in a flow)
//        BuildFlag.isInternal = true
//        testStore.send(.navigate(to: .manualLogin)) { state in
//            state.route = RouteIntent(route: .manualLogin, action: .navigateTo)
//            state.manualCredentialsState = .init()
//        }
//
//        // when
//        testStore.send(.informSecondPasswordDetected)
//        testStore.receive(.manualPairing(.navigate(to: .secondPasswordDetected))) { state in
//            state.manualCredentialsState?.route = RouteIntent(route: .secondPasswordDetected, action: .navigateTo)
//            state.manualCredentialsState?.secondPasswordNoticeState = .init()
//        }
//    }
//
//    func test_second_password_can_be_navigated_to_from_email_login() {
//        // given (we're in a flow)
//        testStore.send(.navigate(to: .emailLogin)) { state in
//            state.route = RouteIntent(route: .emailLogin, action: .navigateTo)
//            state.emailLoginState = .init()
//        }
//        testStore.send(.emailLogin(.navigate(to: .verifyDevice))) { state in
//            state.emailLoginState?.route = RouteIntent(route: .verifyDevice, action: .navigateTo)
//            state.emailLoginState?.verifyDeviceState = .init(emailAddress: "")
//        }
//        testStore.send(.emailLogin(.verifyDevice(.navigate(to: .credentials)))) { state in
//            state.emailLoginState?.verifyDeviceState?.route = RouteIntent(route: .credentials, action: .navigateTo)
//            state.emailLoginState?.verifyDeviceState?.credentialsState = .init()
//        }
//
//        // when
//        testStore.send(.informSecondPasswordDetected)
//        testStore.receive(.emailLogin(.verifyDevice(.credentials(.navigate(to: .secondPasswordDetected))))) { state in
//            state.emailLoginState?.verifyDeviceState?.credentialsState?.route = RouteIntent(route: .secondPasswordDetected, action: .navigateTo)
//            state.emailLoginState?.verifyDeviceState?.credentialsState?.secondPasswordNoticeState = .init()
//        }
//    }
}
