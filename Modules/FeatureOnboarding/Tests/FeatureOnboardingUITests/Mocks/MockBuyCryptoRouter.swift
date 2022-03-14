// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureOnboardingUI
import ToolKit
import UIKit

final class MockBuyCryptoRouter: TransactionsRouterAPI {

    struct RecordedInvocations {
        var presentBuyFlow: [UIViewController] = []
        var navigateToBuyCryptoFlow: [UIViewController] = []
        var navigateToReceiveCryptoFlow: [UIViewController] = []
    }

    struct StubbedResults {
        var presentBuyFlow: AnyPublisher<OnboardingResult, Never> = .just(.abandoned)
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        recordedInvocations.presentBuyFlow.append(presenter)
        return stubbedResults.presentBuyFlow
    }

    func navigateToBuyCryptoFlow(from presenter: UIViewController) {
        recordedInvocations.navigateToBuyCryptoFlow.append(presenter)
    }

    func navigateToReceiveCryptoFlow(from presenter: UIViewController) {
        recordedInvocations.navigateToReceiveCryptoFlow.append(presenter)
    }
}
