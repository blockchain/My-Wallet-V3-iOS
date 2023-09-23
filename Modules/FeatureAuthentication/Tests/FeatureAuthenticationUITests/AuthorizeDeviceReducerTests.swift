// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationUI
import XCTest

@testable import FeatureAuthenticationMock

final class AuthorizeDeviceReducerTests: XCTest {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var mockDeviceVerificationService: DeviceVerificationServiceAPI!
    private var testStore: TestStore<
        AuthorizeDeviceState,
        AuthorizeDeviceAction,
        AuthorizeDeviceState,
        AuthorizeDeviceAction,
        Void
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        mockDeviceVerificationService = MockDeviceVerificationService()
        testStore = TestStore(
            initialState: .init(
                loginRequestInfo: LoginRequestInfo(
                    sessionId: "",
                    base64Str: "",
                    details: DeviceVerificationDetails(originLocation: "", originIP: "", originBrowser: ""),
                    timestamp: Date()
                )
            ),
            reducer: AuthorizeDeviceReducer(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                deviceVerificationService: mockDeviceVerificationService
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        mockDeviceVerificationService = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_handle_authorization_should_set_result() {
        testStore.send(.handleAuthorization(true))
        testStore.receive(.showAuthorizationResult(.success(.noValue))) { state in
            state.authorizationResult = .success
        }
        mockMainQueue.advance()

        testStore.send(.handleAuthorization(false))
        testStore.receive(.showAuthorizationResult(.failure(.requestDenied))) { state in
            state.authorizationResult = .requestDenied
        }
        mockMainQueue.advance()
    }
}
