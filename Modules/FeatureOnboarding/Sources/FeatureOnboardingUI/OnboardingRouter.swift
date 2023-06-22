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
            .flatMap { [weak self] result -> AnyPublisher<OnboardingResult, Never> in
                guard let self else { return .just(.abandoned) }
                let app = app
                // skip old UI tour on super app v1
                if app.remoteConfiguration.yes(if: blockchain.app.configuration.app.superapp.v1.is.enabled) {
                    return .just(.abandoned)
                }

                guard app.currentMode != .pkw else {
                    return .just(.abandoned)
                }

                return presentUITour(from: presenter)
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

    private func presentUITour(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        let subject = PassthroughSubject<OnboardingResult, Never>()
        let view = UITourView(
            close: {
                subject.send(.abandoned)
                subject.send(completion: .finished)
            },
            completion: {
                subject.send(.completed)
                subject.send(completion: .finished)
            }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.modalTransitionStyle = .crossDissolve
        hostingController.modalPresentationStyle = .overFullScreen
        presenter.present(hostingController, animated: true, completion: nil)
        return subject
            .flatMap { [transactionsRouter] result -> AnyPublisher<OnboardingResult, Never> in
                guard case .completed = result else {
                    return .just(.abandoned)
                }

                return Deferred {
                    Future { completion in
                        presenter.dismiss(animated: true) {
                            completion(.success(()))
                        }
                    }
                }
                .flatMap {
                    transactionsRouter.presentBuyFlow(from: presenter)
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        kycRouter.presentEmailVerification(from: presenter)
            .receive(on: mainQueue)
            .eraseToAnyPublisher()
    }
}
