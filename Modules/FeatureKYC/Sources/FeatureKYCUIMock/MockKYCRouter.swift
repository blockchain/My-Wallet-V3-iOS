// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureKYCUI
import PlatformKit
import UIKit

public final class MockKYCRouter: FeatureKYCUI.Routing {

    public struct RecordedInvocations {
        public var routeToEmailVerification: [(emailAddress: String, flowCompletion: (FlowResult) -> Void)] = []
        public var routeToKYC: [(presenter: UIViewController, flowCompletion: (FlowResult) -> Void)] = []
        public var presentEmailVerificationAndKYCIfNeeded: [UIViewController] = []
        public var presentEmailVerificationIfNeeded: [UIViewController] = []
        public var presentKYCIfNeeded: [UIViewController] = []
        public var presentPromptToUnlockMoreTrading: [UIViewController] = []
        public var presentPromptToUnlockMoreTradingIfNeeded: [UIViewController] = []
        public var presentNoticeToUnlockMoreTradingIfNeeded: [UIViewController] = []
        public var presentLimitsOverview: [UIViewController] = []
    }

    public struct StubbedResults {
        public typealias FlowResultPublisher = AnyPublisher<FlowResult, RouterError>

        public var presentEmailVerificationAndKYCIfNeeded: FlowResultPublisher = .failure(.emailVerificationFailed)
        public var presentEmailVerificationIfNeeded: FlowResultPublisher = .failure(.emailVerificationFailed)
        public var presentKYCIfNeeded: FlowResultPublisher = .failure(.kycVerificationFailed)
        public var presentPromptToUnlockMoreTrading: AnyPublisher<FlowResult, Never> = .empty()
        public var presentPromptToUnlockMoreTradingIfNeeded: AnyPublisher<FlowResult, RouterError> = .empty()
        public var presentNoticeToUnlockMoreTradingIfNeeded: AnyPublisher<FlowResult, RouterError> = .just(.abandoned)
    }

    public private(set) var recordedInvocations = RecordedInvocations()
    public var stubbedResults = StubbedResults()

    public func routeToEmailVerification(
        from origin: UIViewController,
        emailAddress: String,
        flowCompletion: @escaping (FlowResult) -> Void
    ) {
        recordedInvocations.routeToEmailVerification.append((emailAddress, flowCompletion))
    }

    public func routeToKYC(
        from presenter: UIViewController,
        requiredTier: KYC.Tier,
        flowCompletion: @escaping (FlowResult) -> Void
    ) {
        recordedInvocations.routeToKYC.append((presenter, flowCompletion))
    }

    public func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requireEmailVerification: Bool,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError> {
        recordedInvocations.presentEmailVerificationAndKYCIfNeeded.append(presenter)
        return stubbedResults.presentEmailVerificationAndKYCIfNeeded
    }

    public func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<FlowResult, RouterError> {
        recordedInvocations.presentEmailVerificationIfNeeded.append(presenter)
        return stubbedResults.presentEmailVerificationIfNeeded
    }

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError> {
        recordedInvocations.presentKYCIfNeeded.append(presenter)
        return stubbedResults.presentKYCIfNeeded
    }

    public func presentPromptToUnlockMoreTrading(
        from presenter: UIViewController
    ) -> AnyPublisher<FlowResult, Never> {
        recordedInvocations.presentPromptToUnlockMoreTrading.append(presenter)
        return stubbedResults.presentPromptToUnlockMoreTrading
    }

    public func presentPromptToUnlockMoreTradingIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError> {
        recordedInvocations.presentPromptToUnlockMoreTradingIfNeeded.append(presenter)
        return stubbedResults.presentPromptToUnlockMoreTradingIfNeeded
    }

    public func presentNoticeToUnlockMoreTradingIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError> {
        recordedInvocations.presentNoticeToUnlockMoreTradingIfNeeded.append(presenter)
        return stubbedResults.presentNoticeToUnlockMoreTradingIfNeeded
    }

    public func presentLimitsOverview(from presenter: UIViewController) {
        recordedInvocations.presentLimitsOverview.append(presenter)
    }
}
