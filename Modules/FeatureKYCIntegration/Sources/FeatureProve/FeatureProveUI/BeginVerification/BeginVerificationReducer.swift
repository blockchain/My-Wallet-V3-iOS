// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import DIKit
import Errors
import FeatureProveDomain
import Localization

struct BeginVerification: ReducerProtocol {
    private typealias LocalizedString = LocalizationConstants.BeginVerification

    enum VerificationResult: Equatable {
        case abandoned
        case failure
        case success(mobileAuthInfo: MobileAuthInfo?)
    }

    let app: AppProtocol
    let mobileAuthInfoService: MobileAuthInfoServiceAPI
    let dismissFlow: (BeginVerification.VerificationResult) -> Void

    init(
        app: AppProtocol,
        mobileAuthInfoService: MobileAuthInfoServiceAPI,
        dismissFlow: @escaping (BeginVerification.VerificationResult) -> Void
    ) {
        self.app = app
        self.mobileAuthInfoService = mobileAuthInfoService
        self.dismissFlow = dismissFlow
    }

    enum Action: Equatable {
        case onAppear
        case fetchMobileAuthInfo
        case onMobileAuthInfoFetched(TaskResult<MobileAuthInfo?>)
        case finishedWithError(NabuError?)
        case onClose
        case onContinue
        case onDismissError
    }

    struct State: Equatable {
        var title: String = LocalizedString.title
        var isLoading: Bool = false
        var mobileAuthInfo: MobileAuthInfo?
        var uxError: UX.Error?
        var termsUrl: URL?
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.termsUrl = try? app.remoteConfiguration.get(
                    blockchain.app.configuration.kyc.integration.prove.begin.verification.privacy.url,
                    as: URL.self
                )
                return .none

            case .onContinue:
                return Effect(value: .fetchMobileAuthInfo)

            case .onClose:
                return .fireAndForget {
                    dismissFlow(.abandoned)
                }

            case .onDismissError:
                return .fireAndForget {
                    dismissFlow(.failure)
                }

            case .fetchMobileAuthInfo:
                state.isLoading = true
                return .task {
                    await .onMobileAuthInfoFetched(
                        TaskResult {
                            try await self.mobileAuthInfoService.getMobileAuthInfo()
                        }
                    )
                }

            case .onMobileAuthInfoFetched(.failure(let error)):
                state.isLoading = false
                return Effect(value: .finishedWithError(error as? NabuError))

            case .onMobileAuthInfoFetched(.success(let mobileAuthInfo)):
                state.isLoading = false
                state.mobileAuthInfo = mobileAuthInfo
                return .fireAndForget {
                    dismissFlow(.success(mobileAuthInfo: mobileAuthInfo))
                }

            case .finishedWithError(let error):
                state.uxError = UX.Error(error: error)
                return .fireAndForget {
                    dismissFlow(.failure)
                }
            }
        }
    }
}

extension BeginVerification {

    static func preview(app: AppProtocol) -> BeginVerification {
        BeginVerification(
            app: app,
            mobileAuthInfoService: NoMobileAuthInfoService(),
            dismissFlow: { _ in }
        )
    }
}

final class NoMobileAuthInfoService: MobileAuthInfoServiceAPI {

    func getMobileAuthInfo() async throws -> MobileAuthInfo? { nil }
}
