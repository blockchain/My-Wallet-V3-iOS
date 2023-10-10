// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum AuthorizeDeviceAction: Equatable {
    case handleAuthorization(Bool)
    case showAuthorizationResult(Result<EmptyValue, AuthorizeVerifyDeviceError>)
}

public struct AuthorizeDeviceState: Equatable {
    public var loginRequestInfo: LoginRequestInfo
    public var authorizationResult: AuthorizationResult?

    public init(
        loginRequestInfo: LoginRequestInfo
    ) {
        self.loginRequestInfo = loginRequestInfo
    }
}

public struct AuthorizeDeviceReducer: Reducer {

    public typealias State = AuthorizeDeviceState
    public typealias Action = AuthorizeDeviceAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        deviceVerificationService: DeviceVerificationServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .handleAuthorization(let authorized):
                return .run { [loginRequestInfo = state.loginRequestInfo] send in
                    do {
                        try await deviceVerificationService
                            .authorizeVerifyDevice(
                                from: loginRequestInfo.sessionId,
                                payload: loginRequestInfo.base64Str,
                                confirmDevice: authorized
                            )
                            .receive(on: mainQueue)
                            .await()
                        await send(.showAuthorizationResult(.success(.noValue)))
                    } catch {
                        await send(.showAuthorizationResult(.failure(error as! AuthorizeVerifyDeviceError)))
                    }
                }
            case .showAuthorizationResult(let result):
                switch result {
                case .success:
                    state.authorizationResult = .success
                case .failure(let error):
                    switch error {
                    case .linkExpired:
                        state.authorizationResult = .linkExpired
                    case .requestDenied:
                        state.authorizationResult = .requestDenied
                    case .network:
                        state.authorizationResult = .unknown
                    case .confirmationRequired:
                        // not an authorization result
                        break
                    }
                }
                return .none
            }
        }
    }
}
