// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureKYCDomain
import FeatureKYCUI
import FeatureOnboardingUI
import FeatureProveDomain
import FeatureProveUI
import FeatureSettingsUI
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

public final class KYCAdapter {

    // MARK: - Properties

    private let router: FeatureKYCUI.Routing

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    public init(router: FeatureKYCUI.Routing = resolve()) {
        self.router = router
    }

    // MARK: - Public Interface

    public func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requireEmailVerification: Bool,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> {
        router
            .presentEmailVerificationAndKYCIfNeeded(
                from: presenter,
                requireEmailVerification: requireEmailVerification,
                requiredTier: requiredTier
            )
            .eraseToAnyPublisher()
    }

    public func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> {
        router
            .presentEmailVerificationIfNeeded(from: presenter)
            .eraseToAnyPublisher()
    }

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> {
        router
            .presentKYCIfNeeded(from: presenter, requiredTier: requiredTier)
            .eraseToAnyPublisher()
    }
}

extension KYCAdapter {

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requireEmailVerification: Bool,
        requiredTier: KYC.Tier,
        completion: @escaping (FeatureKYCUI.FlowResult) -> Void
    ) {
        presentEmailVerificationAndKYCIfNeeded(
            from: presenter,
            requireEmailVerification: requireEmailVerification,
            requiredTier: requiredTier
        )
        .sink(receiveValue: completion)
        .store(in: &cancellables)
    }
}

// MARK: - PlatformUIKit.KYCRouting

extension KYCRouterError {

    public init(_ error: FeatureKYCUI.RouterError) {
        switch error {
        case .emailVerificationFailed:
            self = .emailVerificationFailed
        case .kycVerificationFailed:
            self = .kycVerificationFailed
        case .kycStepFailed:
            self = .kycStepFailed
        }
    }
}

extension KYCRoutingResult {

    public init(_ result: FeatureKYCUI.FlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        case .skipped:
            self = .skipped
        }
    }
}

extension KYCAdapter: PlatformUIKit.KYCRouting {

    public func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentEmailVerificationAndKYCIfNeeded(
            from: presenter,
            requireEmailVerification: false,
            requiredTier: requiredTier
        )
        .mapError(KYCRouterError.init)
        .map(KYCRoutingResult.init)
        .eraseToAnyPublisher()
    }

    public func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentEmailVerificationIfNeeded(from: presenter)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .eraseToAnyPublisher()
    }

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentKYCIfNeeded(from: presenter, requiredTier: requiredTier)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .eraseToAnyPublisher()
    }

    public func presentKYCUpgradeFlow(
        from presenter: UIViewController
    ) -> AnyPublisher<KYCRoutingResult, Never> {
        router.presentPromptToUnlockMoreTrading(from: presenter)
            .map(KYCRoutingResult.init)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func presentKYCUpgradeFlowIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        router.presentPromptToUnlockMoreTradingIfNeeded(from: presenter, requiredTier: requiredTier)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - FeatureOnboardingUI.KYCRouterAPI

extension OnboardingResult {

    public init(_ result: FeatureKYCUI.FlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        case .skipped:
            self = .skipped
        }
    }
}

extension KYCAdapter: FeatureOnboardingUI.KYCRouterAPI {

    public func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        router.presentEmailVerificationIfNeeded(from: presenter)
            .map(OnboardingResult.init)
            .replaceError(with: OnboardingResult.skipped)
            .eraseToAnyPublisher()
    }

    public func presentKYCUpgradePrompt(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        router.presentNoticeToUnlockMoreTradingIfNeeded(from: presenter, requiredTier: .tier2)
            .map(OnboardingResult.init)
            .replaceError(with: OnboardingResult.skipped)
            .eraseToAnyPublisher()
    }

    public func presentTier1KYCIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<OnboardingResult, Never> {
        presentKYCIfNeeded(from: presenter, requiredTier: .tier1)
            .catch(.abandoned)
            .map { (result: KYCRoutingResult) -> OnboardingResult in
                switch result {
                case .abandoned: return .abandoned
                case .completed: return .completed
                case .skipped: return .skipped
                }
            }
            .eraseToAnyPublisher()
    }
}

final class FlowKYCInfoService: FeatureKYCDomain.FlowKYCInfoServiceAPI {

    private let flowKYCInfoService: FeatureProveDomain.FlowKYCInfoServiceAPI

    init(flowKYCInfoService: FeatureProveDomain.FlowKYCInfoServiceAPI = resolve()) {
        self.flowKYCInfoService = flowKYCInfoService
    }

    func isProveFlow() async throws -> Bool? {
        let flowKYCInfo = try await flowKYCInfoService.getFlowKYCInfo()
        return flowKYCInfo?.nextFlow == .prove
    }
}

extension KYCAdapter: FeatureSettingsUI.KYCRouterAPI {

    public func presentLimitsOverview(from presenter: UIViewController) {
        router.presentLimitsOverview(from: presenter)
    }
}

final class KYCProveFlowPresenter: FeatureKYCUI.KYCProveFlowPresenterAPI {

    private let router: FeatureProveDomain.ProveRouterAPI

    init(
        router: FeatureProveDomain.ProveRouterAPI
    ) {
        self.router = router
    }

    func presentFlow(
        country: String,
        state: String?
    ) -> AnyPublisher<KYCProveResult, Never> {
        router.presentFlow(
            proveConfig: .init(
                country: country,
                state: state
            )
        )
        .eraseToEffect()
        .map { KYCProveResult(result: $0) }
        .eraseToAnyPublisher()
    }
}

extension KYCProveResult {
    fileprivate init(result: VerificationResult) {
        switch result {
        case .success:
            self = .success
        case .abandoned:
            self = .abandoned
        case .failure(let errorCode):
            self = .failure(errorCode)
        }
    }
}
