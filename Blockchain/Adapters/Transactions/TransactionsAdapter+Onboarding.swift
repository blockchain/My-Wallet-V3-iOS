// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureOnboardingUI
import FeatureTransactionUI
import MoneyKit
import UIKit

extension TransactionsAdapter: FeatureOnboardingUI.TransactionsRouterAPI {

    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        presentTransactionFlow(toBuy: .bitcoin, from: presenter)
            .map(OnboardingResult.init)
            .eraseToAnyPublisher()
    }

    func navigateToBuyCryptoFlow(from presenter: UIViewController) {
        presentTransactionFlow(to: .buy(nil), from: presenter) { _ in
            // in theory we should be dismissing transaction flow here, but since it dimisses itself, it's not needed
        }
    }

    func navigateToReceiveCryptoFlow(from presenter: UIViewController) {
        presentTransactionFlow(to: .receive(nil), from: presenter) { _ in
            // in theory we should be dismissing transaction flow here, but since it dimisses itself, it's not needed
        }
    }
}

extension OnboardingResult {

    init(_ result: TransactionResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

extension OnboardingResult {

    init(_ result: TransactionFlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

extension TransactionFlowResult {

    init(_ result: OnboardingResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}
