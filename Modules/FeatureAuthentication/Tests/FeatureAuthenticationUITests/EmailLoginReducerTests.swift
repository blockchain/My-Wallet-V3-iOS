// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
@testable import ComposableNavigation
@testable import FeatureAuthenticationUI
import Localization
import ToolKit
import XCTest

// Mocks
@testable import AnalyticsKitMock
@testable import FeatureAuthenticationMock
@testable import ToolKitMock

final class EmailLoginReducerTests: XCTestCase {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        EmailLoginState,
        EmailLoginAction,
        EmailLoginState,
        EmailLoginAction,
        EmailLoginEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        testStore = TestStore(
            initialState: .init(),
            reducer: emailLoginReducer,
            environment: EmailLoginEnvironment(
                app: App.test,
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                sessionTokenService: MockSessionTokenService(),
                deviceVerificationService: MockDeviceVerificationService(),
                errorRecorder: MockErrorRecorder(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .mock(),
                walletFetcherService: WalletFetcherServiceMock().mock(),
                accountRecoveryService: MockAccountRecoveryService(),
                recaptchaService: MockRecaptchaService()
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = EmailLoginState()
        XCTAssertNil(state.verifyDeviceState)
        XCTAssertNil(state.route)
        XCTAssertEqual(state.emailAddress, "")
        XCTAssertFalse(state.isEmailValid)
    }

//    func test_on_appear_should_setup_session_token() {
//        testStore.assert(
//            .send(.onAppear),
//            .receive(.setupSessionToken),
//            .do { self.mockMainQueue.advance() },
//            .receive(.none)
//        )
//    }

    func test_send_device_verification_email_success() {
        let validEmail = "valid@example.com"
        testStore.send(.didChangeEmailAddress(validEmail)) { state in
            state.emailAddress = validEmail
            state.isEmailValid = true
        }
        testStore.send(.sendDeviceVerificationEmail) { state in
            state.isLoading = true
            state.verifyDeviceState?.sendEmailButtonIsLoading = true
        }
        mockMainQueue.advance()
        testStore.receive(.didSendDeviceVerificationEmail(.success(.noValue))) { state in
            state.isLoading = false
            state.verifyDeviceState?.sendEmailButtonIsLoading = false
        }
        testStore.receive(.navigate(to: .verifyDevice)) { state in
            state.verifyDeviceState = .init(emailAddress: validEmail)
            state.route = RouteIntent(route: .verifyDevice, action: .navigateTo)
        }
    }

    func test_send_device_verification_email_failure_network_error() {
        // should still go to verify device screen if it is a network error
        testStore.send(.didSendDeviceVerificationEmail(.failure(.networkError(.unknown))))
        testStore.receive(.navigate(to: .verifyDevice)) { state in
            state.verifyDeviceState = .init(emailAddress: "")
            state.route = RouteIntent(route: .verifyDevice, action: .navigateTo)
        }
    }

    func test_send_device_verification_email_failure_missing_session_token() {
        // should not go to verify device screen if it is a missing session token error
        testStore.send(.didSendDeviceVerificationEmail(.failure(.missingSessionToken)))
        testStore.receive(
            .alert(
                .show(
                    title: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SignInError.title,
                    message: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SignInError.message
                )
            )
        ) { state in
            state.alert = AlertState(
                title: TextState(
                    verbatim: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SignInError.title
                ),
                message: TextState(
                    verbatim: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SignInError.message
                ),
                dismissButton: .default(
                    TextState(LocalizationConstants.continueString),
                    action: .send(.alert(.dismiss))
                )
            )
        }
    }

    func test_send_device_verification_email_failure_recaptcha_error() {
        // should not go to verify device screen if it is a recaptcha error
        testStore.send(.didSendDeviceVerificationEmail(.failure(.recaptchaError(.unknownError))))
        testStore.receive(
            .alert(
                .show(
                    title: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SignInError.title,
                    message: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SignInError.message
                )
            )
        ) { state in
            state.alert = AlertState(
                title: TextState(
                    verbatim: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SignInError.title
                ),
                message: TextState(
                    verbatim: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SignInError.message
                ),
                dismissButton: .default(
                    TextState(LocalizationConstants.continueString),
                    action: .send(.alert(.dismiss))
                )
            )
        }
    }
}
