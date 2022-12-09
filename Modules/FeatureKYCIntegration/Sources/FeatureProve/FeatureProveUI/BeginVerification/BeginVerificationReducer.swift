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
        case success(phone: String?)
        case abandoned
    }

    let app: AppProtocol
    let phoneVerificationService: PhoneVerificationServiceAPI
    let mobileAuthInfoService: MobileAuthInfoServiceAPI
    let completion: (BeginVerification.VerificationResult) -> Void

    init(
        app: AppProtocol,
        phoneVerificationService: PhoneVerificationServiceAPI,
        mobileAuthInfoService: MobileAuthInfoServiceAPI,
        completion: @escaping (BeginVerification.VerificationResult) -> Void
    ) {
        self.app = app
        self.phoneVerificationService = phoneVerificationService
        self.mobileAuthInfoService = mobileAuthInfoService
        self.completion = completion
    }

    enum Action: Equatable {
        case onAppear
        case checkPhoneVerfication
        case onCheckPhoneVerficationFetched(TaskResult<PhoneVerification>)
        case fetchMobileAuthInfo
        case onMobileAuthInfoFetched(TaskResult<MobileAuthInfo?>)
        case handleError(NabuError?)
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
                return Effect(value: .checkPhoneVerfication)

            case .onClose:
                return .fireAndForget {
                    completion(.abandoned)
                }

            case .checkPhoneVerfication:
                state.isLoading = true
                return .task {
                    await .onCheckPhoneVerficationFetched(
                        TaskResult {
                            try await phoneVerificationService.fetchInstantLinkPossessionStatus()
                        }
                    )
                }

            case .onCheckPhoneVerficationFetched(.success(let phoneVerification)):
                state.isLoading = false
                switch phoneVerification.isVerified {
                case true:
                    return .fireAndForget {
                        completion(.success(phone: phoneVerification.phone))
                    }
                case false:
                    return Effect(value: .fetchMobileAuthInfo)
                }

            case .onCheckPhoneVerficationFetched(.failure):
                return Effect(value: .fetchMobileAuthInfo)

            case .fetchMobileAuthInfo:
                state.isLoading = true
                return .task {
                    await .onMobileAuthInfoFetched(
                        TaskResult {
                            try await mobileAuthInfoService.getMobileAuthInfo()
                        }
                    )
                }

            case .onMobileAuthInfoFetched(.success(let mobileAuthInfo)):
                state.isLoading = false
                state.mobileAuthInfo = mobileAuthInfo
                return .fireAndForget {
                    completion(.success(phone: mobileAuthInfo?.phone))
                }

            case .onMobileAuthInfoFetched(.failure(let error)):
                state.isLoading = false
                return Effect(value: .handleError(error as? NabuError))

            case .handleError(let error):
                state.uxError = UX.Error(error: error)
                return .none

            case .onDismissError:
                state.uxError = nil
                return .none
            }
        }
    }
}

extension BeginVerification {

    static func preview(app: AppProtocol) -> BeginVerification {
        BeginVerification(
            app: app,
            phoneVerificationService: NoPhoneVerificationService(),
            mobileAuthInfoService: NoMobileAuthInfoService(),
            completion: { _ in }
        )
    }
}

final class NoMobileAuthInfoService: MobileAuthInfoServiceAPI {

    func getMobileAuthInfo() async throws -> MobileAuthInfo? { nil }
}
