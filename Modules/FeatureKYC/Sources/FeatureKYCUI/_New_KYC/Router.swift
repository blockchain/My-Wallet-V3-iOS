// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import FeatureKYCDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import SwiftUI
import ToolKit
import UIComponentsKit
import UIKit

public enum FlowResult {
    case abandoned
    case completed
}

public enum RouterError: Error {
    case emailVerificationFailed
    case kycVerificationFailed
    case kycStepFailed
}

private enum UserDefaultsKey: String {
    case didPresentNoticeToUnlockTradingFeatures
}

public protocol Routing {

    /// Uses the passed-in `ViewController`to modally present another `ViewController` wrapping the entire Email Verification Flow.
    /// - Parameters:
    ///   - presenter: The `ViewController` presenting the Email Verification Flow
    ///   - emailAddress: The initial email address to verify. Note that users may change their email address in the course of the verification flow.
    ///   - flowCompletion: A closure called after the Email Verification Flow completes successully (with the email address being verified).
    func routeToEmailVerification(
        from presenter: UIViewController,
        emailAddress: String,
        flowCompletion: @escaping (FlowResult) -> Void
    )

    /// Uses the passed-in `ViewController`to modally present another `ViewController` wrapping the entire KYC Flow.
    /// - Parameters:
    ///   - presenter: The `ViewController` presenting the KYC Flow
    ///   - flowCompletion: A closure called after the KYC Flow completes successully (with the email address being verified).
    func routeToKYC(
        from presenter: UIViewController,
        requiredTier: KYC.Tier,
        flowCompletion: @escaping (FlowResult) -> Void
    )

    /// Checks if the user email is verified. If not, the Email Verification Flow will be presented.
    /// Then, the KYC status will be checked against the required tier. If the user is on a lower tier, the KYC Flow will be presented.
    /// - Parameters:
    ///   The `ViewController` presenting the Email Verification and KYC Flows
    ///   - requiredTier: the minimum KYC tier the user needs to be on to avoid presenting the KYC Flow
    func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requireEmailVerification: Bool,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError>

    /// Checks if the user email is verified. If not, the Email Verification Flow will be presented.
    /// The `ViewController` presenting the Email Verification Flow Flow
    func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<FlowResult, RouterError>

    /// Checks the KYC status of the user against the required tier. If the user is on a lower tier, the KYC Flow will be presented.
    /// - Parameters:
    ///   The `ViewController` presenting the KYC Flow
    ///   - requiredTier: the minimum KYC tier the user needs to be on to avoid presenting the KYC Flow
    func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError>

    /// Presents a screen prompting the user to upgrade to Gold Tier. If the user tries to upgrade, the KYC Flow will be presented on top of the prompt.
    /// - Parameter presenter: The `ViewController` that will present the screen
    /// - Returns: A `Combine.Publisher` sending a single value before completing.
    func presentPromptToUnlockMoreTrading(
        from presenter: UIViewController
    ) -> AnyPublisher<FlowResult, Never>

    /// Checks the KYC status of the user against the required tier. If the user is on a lower tier, presents a screen prompting the user to upgrade tier.
    /// If the user tries to upgrade, the KYC Flow will be presented on top of the prompt.
    /// - Parameters:
    ///   - from: the `ViewController` presenting the KYC Flow
    ///   - requiredTier: the minimum KYC tier the user needs to be on to avoid presenting the KYC Flow
    func presentPromptToUnlockMoreTradingIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError>

    /// Checks the KYC status of the user against the required tier. If the user is on a lower tier, presents an alert asking the user to upgrade tier.
    /// If the user tries to upgrade, the KYC Flow will be presented on top of the prompt.
    ///
    /// - NOTE: The difference between this method and `presentPromptToUnlockMoreTradingIfNeeded` is in the UI. This method presents an
    /// alert first. If the user opts-in to upgrade, `presentPromptToUnlockMoreTradingIfNeeded` is called to present the actual prompt to upgrade.
    ///
    /// - Parameters:
    ///   - from: the `ViewController` presenting the KYC Flow
    ///   - requiredTier: the minimum KYC tier the user needs to be on to avoid presenting the KYC Flow
    func presentNoticeToUnlockMoreTradingIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError>

    /// Presents a limits overview screen
    func presentLimitsOverview(from presenter: UIViewController)
}

/// A class that encapsulates routing logic for the KYC flow. Use this to present the app user with any part of the KYC flow.
public class Router: Routing {

    private let legacyRouter: PlatformUIKit.KYCRouterAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let loadingViewPresenter: PlatformUIKit.LoadingViewPresenting
    private let emailVerificationService: FeatureKYCDomain.EmailVerificationServiceAPI
    private let kycService: PlatformKit.KYCTiersServiceAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let openMailApp: (@escaping (Bool) -> Void) -> Void
    private let openURL: (URL) -> Void
    private let userDefaults: UserDefaults

    // This should be removed once the legacy router is deleted
    private var cancellables = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()

    public init(
        analyticsRecorder: AnalyticsEventRecorderAPI,
        loadingViewPresenter: PlatformUIKit.LoadingViewPresenting,
        legacyRouter: PlatformUIKit.KYCRouterAPI,
        kycService: PlatformKit.KYCTiersServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
        emailVerificationService: FeatureKYCDomain.EmailVerificationServiceAPI,
        openMailApp: @escaping (@escaping (Bool) -> Void) -> Void,
        openURL: @escaping (URL) -> Void,
        userDefaults: UserDefaults = .standard
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.loadingViewPresenter = loadingViewPresenter
        self.legacyRouter = legacyRouter
        self.kycService = kycService
        self.featureFlagsService = featureFlagsService
        self.emailVerificationService = emailVerificationService
        self.openMailApp = openMailApp
        self.openURL = openURL
        self.userDefaults = userDefaults
    }

    public func routeToEmailVerification(
        from presenter: UIViewController,
        emailAddress: String,
        flowCompletion: @escaping (FlowResult) -> Void
    ) {
        presenter.present(
            EmailVerificationView(
                store: .init(
                    initialState: .init(emailAddress: emailAddress),
                    reducer: emailVerificationReducer,
                    environment: buildEmailVerificationEnvironment(
                        emailAddress: emailAddress,
                        flowCompletion: flowCompletion
                    )
                )
            )
        )
    }

    public func routeToKYC(
        from presenter: UIViewController,
        requiredTier: KYC.Tier,
        flowCompletion: @escaping (FlowResult) -> Void
    ) {
        // NOTE: you must retain the router to get the flow completion
        presentKYC(from: presenter, requiredTier: requiredTier)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: flowCompletion)
            .store(in: &cancellables)
    }

    public func presentKYC(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, Never> {
        legacyRouter.start(tier: requiredTier, parentFlow: .simpleBuy)
        return Observable.merge(
            legacyRouter.kycStopped
                .map { _ in FlowResult.abandoned },
            legacyRouter.kycFinished
                .map { _ in FlowResult.completed }
        )
        // Taking one as Single ensures the Publisher completes. This fixes a bug where receiveValue on sink was called multiple times.
        .take(1)
        .asSingle()
        .asPublisher()
        .replaceError(with: FlowResult.abandoned) // should not fail, but just in case
        .eraseToAnyPublisher()
    }

    public func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requireEmailVerification: Bool,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError> {
        // step 1: check email verification status and present email verification flow if email is unverified.
        presentEmailVerificationIfNeeded(from: presenter)
            // step 2: check KYC status and present KYC flow if user has verified their email address.
            .flatMap { [presentKYCIfNeeded] result -> AnyPublisher<FlowResult, RouterError> in
                if requireEmailVerification {
                    guard case .completed = result else {
                        return .just(.abandoned)
                    }
                }
                return presentKYCIfNeeded(presenter, requiredTier)
            }
            .eraseToAnyPublisher()
    }

    public func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<FlowResult, RouterError> {
        emailVerificationService
            // step 1: check email verification status.
            .checkEmailVerificationStatus()
            .mapError { _ in
                RouterError.emailVerificationFailed
            }
            .receive(on: DispatchQueue.main)
            .handleLoaderForLifecycle(loader: loadingViewPresenter)
            // step 2: present email verification screen, if needed.
            .flatMap { response -> AnyPublisher<FlowResult, RouterError> in
                switch response.status {
                case .verified:
                    // The user's email address is verified; no need to do anything. Just move on.
                    return .just(.completed)

                case .unverified:
                    // The user's email address in NOT verified; present email verification flow.
                    let publisher = PassthroughSubject<FlowResult, RouterError>()
                    self.routeToEmailVerification(from: presenter, emailAddress: response.emailAddress) { result in
                        // Because the caller of the API doesn't know if the flow got presented, we should dismiss it here
                        presenter.dismiss(animated: true) {
                            switch result {
                            case .abandoned:
                                publisher.send(.abandoned)
                            case .completed:
                                publisher.send(.completed)
                            }
                            publisher.send(completion: .finished)
                        }
                    }
                    return publisher.eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError> {
        guard requiredTier > .tier0 else {
            return .just(.completed)
        }

        // step 1: check KYC status.
        return kycService
            .fetchTiers()
            .receive(on: DispatchQueue.main)
            .mapError { _ in RouterError.kycStepFailed }
            .handleLoaderForLifecycle(loader: loadingViewPresenter)
            .flatMap { [routeToKYC] userTiers -> AnyPublisher<FlowResult, RouterError> in
                // step 2a: Route to KYC if the current user's tier is less than Tier 2.
                // NOTE: By guarding against Tier 1 we ensure SDD checks are performed for Tier 1 users to determine whether they are Tier 3.
                guard userTiers.latestApprovedTier > .tier1 else {
                    return Deferred { [routeToKYC] in
                        Future<FlowResult, RouterError> { futureCompletion in
                            routeToKYC(presenter, requiredTier) { result in
                                futureCompletion(.success(result))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }

                // step 2a: if the current user's tier is greater or equal than the required tier, complete.
                guard userTiers.latestApprovedTier < requiredTier else {
                    return .just(.completed)
                }
                // step 2b: else present the kyc flow
                return Deferred {
                    Future<FlowResult, RouterError> { futureCompletion in
                        routeToKYC(presenter, requiredTier) { result in
                            futureCompletion(.success(result))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func presentPromptToUnlockMoreTradingIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError> {
        guard requiredTier > .tier0 else {
            return .just(.completed)
        }
        let presentClosure = presentPromptToUnlockMoreTrading(from:currentUserTier:)
        return kycService
            .fetchTiers()
            .receive(on: DispatchQueue.main)
            .mapError { _ in RouterError.kycStepFailed }
            .flatMap { userTiers -> AnyPublisher<FlowResult, RouterError> in
                let currentTier = userTiers.latestApprovedTier
                guard currentTier < requiredTier else {
                    return .just(.completed)
                }
                return presentClosure(presenter, currentTier)
                    .mapError()
            }
            .eraseToAnyPublisher()
    }

    public func presentPromptToUnlockMoreTrading(
        from presenter: UIViewController
    ) -> AnyPublisher<FlowResult, Never> {
        let presentClosure = presentPromptToUnlockMoreTrading(from:currentUserTier:)
        return kycService
            .fetchTiers()
            .map(\.latestApprovedTier)
            .replaceError(with: .tier0)
            .receive(on: DispatchQueue.main)
            .flatMap { currentTier -> AnyPublisher<FlowResult, Never> in
                presentClosure(presenter, currentTier)
            }
            .eraseToAnyPublisher()
    }

    public func presentNoticeToUnlockMoreTradingIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, RouterError> {
        let presentNotice = presentNoticeToUnlockMoreTrading(from:currentUserTier:)
        // Check if user needs to be presented with notice
        return kycService.tiers
            .replaceError(with: RouterError.kycVerificationFailed)
            .receive(on: DispatchQueue.main)
            .flatMap { [userDefaults] userTiers -> AnyPublisher<FlowResult, RouterError> in
                // if user is Tier 1 and can complete Tier 2 show notice
                // otherwise just complete the process
                let didPresentNotice = userDefaults.bool(
                    forKey: UserDefaultsKey.didPresentNoticeToUnlockTradingFeatures.rawValue
                )
                let canPresentNotice = userTiers.isTier1Approved && userTiers.canCompleteTier2
                guard !didPresentNotice, canPresentNotice else {
                    return .just(.completed)
                }

                userDefaults.set(true, forKey: UserDefaultsKey.didPresentNoticeToUnlockTradingFeatures.rawValue)
                userDefaults.synchronize()

                return presentNotice(presenter, userTiers.latestApprovedTier)
                    .setFailureType(to: RouterError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func presentLimitsOverview(from presenter: UIViewController) {
        func internalPresentKYC(from presenter: UIViewController, requiredTier: KYC.Tier) {
            presentKYC(from: presenter, requiredTier: requiredTier)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { _ in
                    // no-op
                })
                .store(in: &cancellables)
        }
        return featureFlagsService.isEnabled(.remote(.newLimitsUIEnabled))
            .receive(on: DispatchQueue.main)
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .sink { [kycService, disposeBag, internalPresentKYC, openURL] newLimitsUIEnabled in
                guard newLimitsUIEnabled else {
                    KYCTiersViewController
                        .routeToTiers(fromViewController: presenter)
                        .disposed(by: disposeBag)
                    return
                }
                let view = TradingLimitsView(
                    store: .init(
                        initialState: TradingLimitsState(),
                        reducer: tradingLimitsReducer,
                        environment: TradingLimitsEnvironment(
                            close: {
                                presenter.dismiss(animated: true, completion: nil)
                            },
                            openURL: openURL,
                            presentKYCFlow: { requiredTier in
                                presenter.dismiss(animated: true) {
                                    internalPresentKYC(presenter, requiredTier)
                                }
                            },
                            fetchLimitsOverview: kycService.fetchOverview
                        )
                    )
                )
                presenter.present(view)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Helpers

private typealias L10n = LocalizationConstants.NewKYC

extension Router {

    func buildEmailVerificationEnvironment(
        emailAddress: String,
        flowCompletion: @escaping (FlowResult) -> Void
    ) -> EmailVerificationEnvironment {
        EmailVerificationEnvironment(
            analyticsRecorder: analyticsRecorder,
            emailVerificationService: emailVerificationService,
            flowCompletionCallback: flowCompletion,
            openMailApp: { [openMailApp] in
                .future { callback in
                    openMailApp { result in
                        callback(.success(result))
                    }
                }
            }
        )
    }

    private func presentPromptToUnlockMoreTrading(
        from presenter: UIViewController,
        currentUserTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, Never> {
        let publisher = PassthroughSubject<FlowResult, Never>()
        let view = UnlockTradingView(
            store: .init(
                initialState: UnlockTradingState(currentUserTier: currentUserTier),
                reducer: unlockTradingReducer,
                environment: UnlockTradingEnvironment(
                    dismiss: {
                        presenter.dismiss(animated: true) {
                            publisher.send(.abandoned)
                            publisher.send(completion: .finished)
                        }
                    },
                    unlock: { [routeToKYC] requiredTier in
                        routeToKYC(presenter, requiredTier) { result in
                            // KYC is presented on top of prompt. Only dismiss KYC.
                            // KYC id dismissed automatically.
                            // When the kyc flow is abandoned, we don't complete
                            // so users have another shot at going through it
                            guard case .completed = result else {
                                return
                            }
                            presenter.dismiss(animated: true) {
                                publisher.send(.completed)
                                publisher.send(completion: .finished)
                            }
                        }
                    }
                )
            )
        )
        presenter.present(view)
        return publisher.eraseToAnyPublisher()
    }

    private func presentNoticeToUnlockMoreTrading(
        from presenter: UIViewController,
        currentUserTier: KYC.Tier
    ) -> AnyPublisher<FlowResult, Never> {
        let subject = PassthroughSubject<FlowResult, Never>()

        let alert = Alert(
            topView: {
                Image("icon-not-verified", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
            },
            title: L10n.UnlockTradingAlert.title,
            message: L10n.UnlockTradingAlert.message,
            buttons: [
                Alert.Button(title: L10n.UnlockTradingAlert.primaryCTA, style: .primary) {
                    presenter.dismiss(animated: true) {
                        subject.send(.completed)
                        subject.send(completion: .finished)
                    }
                }
            ],
            close: {
                presenter.dismiss(animated: true) {
                    subject.send(.abandoned)
                    subject.send(completion: .finished)
                }
            }
        )

        let alertVC = UIHostingController(rootView: alert)
        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.view.backgroundColor = .clear
        presenter.present(alertVC, animated: true, completion: nil)

        let upgradeClosure = presentPromptToUnlockMoreTrading(from:currentUserTier:)
        return subject.flatMap { result -> AnyPublisher<FlowResult, Never> in
            guard case .completed = result else {
                return .just(result)
            }
            return upgradeClosure(presenter, currentUserTier)
        }
        .eraseToAnyPublisher()
    }
}
