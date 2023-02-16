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
    func presentKYCUpgradePrompt(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
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
    let featureFlagsService: FeatureFlagsServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    public init(
        app: AppProtocol = resolve(),
        kycRouter: KYCRouterAPI = resolve(),
        transactionsRouter: TransactionsRouterAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.app = app
        self.kycRouter = kycRouter
        self.transactionsRouter = transactionsRouter
        self.featureFlagsService = featureFlagsService
        self.mainQueue = mainQueue
    }

    // MARK: - Onboarding Routing

    public func presentPostSignUpOnboarding(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        // Step 1: present email verification
        presentEmailVerification(from: presenter)
            .flatMap { [weak self] result -> AnyPublisher<OnboardingResult, Never> in
                guard let self else { return .just(.abandoned) }
                let app = self.app
                if app.remoteConfiguration.yes(if: blockchain.ux.onboarding.promotion.cowboys.is.enabled),
                    app.state.yes(if: blockchain.user.is.cowboy.fan)
                {
                    if result == .completed {
                        return Task<OnboardingResult, Error>.Publisher(priority: .userInitiated) {
                            try await self.presentCowboyPromotion(from: presenter)
                        }
                        .replaceError(with: .abandoned)
                        .eraseToAnyPublisher()
                    } else {
                        return .just(.abandoned)
                    }
                }
                // skip old UI tour on super app v1
                if app.remoteConfiguration.yes(if: blockchain.app.configuration.app.superapp.v1.is.enabled) {
                    return .just(.abandoned)
                }

                guard app.currentMode != .pkw else {
                    return .just(.abandoned)
                }

                return self.presentUITour(from: presenter)
            }
            .eraseToAnyPublisher()
    }

    public func presentPostSignInOnboarding(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        kycRouter.presentKYCUpgradePrompt(from: presenter)
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
        featureFlagsService.isEnabled(.showEmailVerificationInOnboarding)
            .receive(on: mainQueue)
            .flatMap { [kycRouter] shouldShowEmailVerification -> AnyPublisher<OnboardingResult, Never> in
                guard shouldShowEmailVerification else {
                    return .just(.completed)
                }
                return kycRouter.presentEmailVerification(from: presenter)
            }
            .eraseToAnyPublisher()
    }

    private func presentCowboyPromotion(from presenter: UIViewController) async throws -> OnboardingResult {

        if try app.state.get(blockchain.user.account.tier) == blockchain.user.account.tier.none[] {

            guard case .completed = await present(
                promotion: blockchain.ux.onboarding.promotion.cowboys.welcome,
                from: presenter
            ) else { return .abandoned }

            let kyc = try await app
                .on(blockchain.ux.kyc.event.did.finish, blockchain.ux.kyc.event.did.stop, blockchain.ux.kyc.event.did.cancel)
                .stream()
                .next()

            guard
                kyc.origin ~= blockchain.ux.kyc.event.did.finish
            else { return .abandoned }

            try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)

            guard case .completed = await present(
                promotion: blockchain.ux.onboarding.promotion.cowboys.raffle,
                from: presenter
            ) else { return .abandoned }

            let transaction = try await app
                .on(blockchain.ux.transaction["buy"].event.did.finish, blockchain.ux.transaction["buy"].event.execution.status.completed)
                .stream()
                .next()

            guard
                transaction.origin ~= blockchain.ux.transaction.event.execution.status.completed
            else { return .abandoned }

            try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
        }

        return await present(
            promotion: blockchain.ux.onboarding.promotion.cowboys.verify.identity,
            from: presenter
        )
    }

    @MainActor private func present(
        promotion: L & I_blockchain_ux_onboarding_type_promotion,
        from presenter: UIViewController
    ) async -> OnboardingResult {
        do {
            let story = promotion.story
            let view = try await PromotionView(promotion, ux: app.get(story))
                .app(app)
            await MainActor.run {
                presenter.present(UIHostingController(rootView: view), animated: true)
            }
            let event = try await app.on(story.action.then.launch.url, story.action.then.close).stream().next()
            switch event.tag {
            case story.action.then.launch.url:
                return .completed
            default:
                return .abandoned
            }
        } catch {
            return .abandoned
        }
    }
}
