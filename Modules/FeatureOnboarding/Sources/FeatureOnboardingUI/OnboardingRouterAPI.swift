// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import UIKit

public enum OnboardingResult {
    case abandoned
    case completed
    case skipped
}

public protocol OnboardingRouterAPI {
    func presentPostSignUpOnboarding(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
    func presentRequiredCryptoBalanceView(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
}
