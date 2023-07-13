// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineSchedulers
import DIKit
import Errors
import SwiftUI
import ToolKit
import UIKit

public protocol KYCRouterAPI {
    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
}

public protocol TransactionsRouterAPI {
    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
    func navigateToBuyCryptoFlow(from presenter: UIViewController)
    func navigateToReceiveCryptoFlow(from presenter: UIViewController)
}

public final class OnboardingRouter: OnboardingRouterAPI {

    // MARK: - Properties

    let app: AppProtocol
    let kycRouter: KYCRouterAPI
    let transactionsRouter: TransactionsRouterAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    public init(
        app: AppProtocol = resolve(),
        kycRouter: KYCRouterAPI = resolve(),
        transactionsRouter: TransactionsRouterAPI = resolve(),
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.app = app
        self.kycRouter = kycRouter
        self.transactionsRouter = transactionsRouter
        self.mainQueue = mainQueue
    }

    // MARK: - Onboarding Routing

    public func presentPostSignUpOnboarding(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        // Step 1: present email verification
        presentEmailVerification(from: presenter)
            .flatMap { _ -> AnyPublisher<OnboardingResult, Never> in
                .just(.abandoned)
            }
            .eraseToAnyPublisher()
    }

    public func presentRequiredCryptoBalanceView(
        from presenter: UIViewController
    ) -> AnyPublisher<OnboardingResult, Never> {
        let subject = PassthroughSubject<OnboardingResult, Never>()
        let view = CryptoBalanceRequiredView(
            store: .init(
                initialState: (),
                reducer: CryptoBalanceRequired.reducer,
                environment: CryptoBalanceRequired.Environment(
                    close: {
                        presenter.dismiss(animated: true) {
                            subject.send(.abandoned)
                            subject.send(completion: .finished)
                        }
                    },
                    presentBuyFlow: { [transactionsRouter] in
                        presenter.dismiss(animated: true) {
                            transactionsRouter.navigateToBuyCryptoFlow(from: presenter)
                        }
                    },
                    presentRequestCryptoFlow: { [transactionsRouter] in
                        presenter.dismiss(animated: true) {
                            transactionsRouter.navigateToReceiveCryptoFlow(from: presenter)
                        }
                    }
                )
            )
        )
        presenter.present(view)
        return subject.eraseToAnyPublisher()
    }

    // MARK: - Helper Methods

    private func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        kycRouter.presentEmailVerification(from: presenter)
            .receive(on: mainQueue)
            .eraseToAnyPublisher()
    }
}
