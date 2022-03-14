// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureOnboardingUI
import ToolKit
import UIKit

final class MockOnboardingEmailVerificationRouter: FeatureOnboardingUI.KYCRouterAPI {

    struct RecordedInvocations {
        var presentEmailVerification: [UIViewController] = []
        var presentKYCUpgradePrompt: [UIViewController] = []
    }

    struct StubbedResults {
        var presentEmailVerification: AnyPublisher<OnboardingResult, Never> = .just(.abandoned)
        var presentKYCUpgradePrompt: AnyPublisher<OnboardingResult, Never> = .just(.abandoned)
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        recordedInvocations.presentEmailVerification.append(presenter)
        return stubbedResults.presentEmailVerification
    }

    func presentKYCUpgradePrompt(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        recordedInvocations.presentKYCUpgradePrompt.append(presenter)
        return stubbedResults.presentKYCUpgradePrompt
    }
}
