// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DIKit
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import ToolKit

/// PIN creation / changing / authentication. Responsible for routing screens during flow.
public final class PinRouter: NSObject {

    // MARK: - Properties

    /// The origin of the pin flow
    public let flow: PinRouting.Flow

    /// Returns `true` in case login authentication is currently being displayed
    public var isDisplayingLoginAuthentication: Bool {
        isBeingDisplayed && flow.isLoginAuthentication
    }

    /// Is being displayed right now
    private(set) var isBeingDisplayed = false

    /// Wrap up the current flow and move to the next
    private let completion: PinRouting.RoutingType.Forward?

    /// Weakly references the pin navigation controller as we don't want to keep it while it's not currently presented
    private weak var navigationController: UINavigationController!

    /// A recorder for errors
    private let recorder: Recording

    private let webViewService: WebViewServiceAPI

    // MARK: - Setup

    public init(
        flow: PinRouting.Flow,
        recorder: Recording = DIKit.resolve(tag: "CrashlyticsRecorder"),
        completion: PinRouting.RoutingType.Forward? = nil,
        webViewService: WebViewServiceAPI = resolve()
    ) {
        self.flow = flow
        self.recorder = recorder
        self.completion = completion
        self.webViewService = webViewService
        super.init()
    }

    // MARK: - API

    /// Executes the pin flow according to the `flow` value provided during initialization
    public func execute() {
        guard !isBeingDisplayed else { return }

        isBeingDisplayed = true
        switch flow {
        case .create:
            create()
        case .createPin:
            create()
        case .change:
            change()
        case .authenticate(from: let origin, logoutRouting: _):
            authenticate(from: origin)
        case .enableBiometrics: // Here the origin is `.foreground`
            authenticate(from: flow.origin)
        }
    }

    /// Cleanup immediately any currently running pin flow
    public func cleanup() {
        DispatchQueue.main.async { [weak self] in
            self?.finish(animated: false, completedSuccessfully: false)
        }
    }

    public func effectHandling(_ effect: PinRouting.RoutingType.EffectType) {
        switch effect {
        case .openLink(let url):
            webViewService.openSafari(url: url, from: navigationController)
        }
    }
}

// MARK: - Private Logic

extension PinRouter {

    // MARK: - Entry points of pin flow

    /// Invokes authentication using pin code
    private func authenticate(from origin: PinRouting.Flow.Origin) {
        let forwardRouting: PinRouting.RoutingType.Forward = { [weak self] input in
            self?.finish(completionInput: input)
        }
        let useCase: PinScreenUseCase
        switch self.flow {
        case .authenticate:
            useCase = .authenticateOnLogin
        case .enableBiometrics:
            useCase = .authenticateBeforeEnablingBiometrics
        default: // Shouldn't arrive here
            return
        }

        // Add cleanup to logout
        let flow = PinRouting.Flow.authenticate(from: origin) { [weak self] in
            self?.cleanup()
            self?.flow.logoutRouting?()
        }
        let effectHandling: PinRouting.RoutingType.Effect = { [weak self] effect in
            self?.effectHandling(effect)
        }
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: PinInteractor(),
            biometryProvider: BiometryProvider(),
            appSettings: DIKit.resolve(),
            cloudSettings: DIKit.resolve(),
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: DIKit.resolve(tag: "CrashlyticsRecorder"),
            credentialsStore: DIKit.resolve(),
            backwardRouting: nil,
            forwardRouting: forwardRouting,
            performEffect: effectHandling,
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        let pinViewController = PinScreenViewController(using: presenter)
        if useCase.isAuthenticateOnLogin {
            authenticateOnLogin(using: pinViewController)
        } else {
            present(viewController: pinViewController)
        }
    }

    /// Leads to authentication flow on logic.
    /// - parameter pinViewController: Pin view controller to be the first screen
    private func authenticateOnLogin(using pinViewController: UIViewController) {
        let pinInput = LoginContainerViewController.Input.viewController(pinViewController)
        let containerViewController = LoginContainerViewController(using: [pinInput])
        present(viewController: containerViewController)
    }

    /// Invokes a PIN change flow in which a user has to verify the old PIN -> select a new PIN -> create a new PIN
    private func change() {
        let backwardRouting: PinRouting.RoutingType.Backward = { [weak self] in
            self?.finish()
        }
        let forwardRouting: PinRouting.RoutingType.Forward = { [weak self] input in
            self?.select(previousPin: input.pin)
        }

        // Add cleanup to logout
        let flow = PinRouting.Flow.change(parent: UnretainedContentBox(flow.parent)) { [weak self] in
            self?.cleanup()
            self?.flow.logoutRouting?()
        }
        let effectHandling: PinRouting.RoutingType.Effect = { [weak self] effect in
            self?.effectHandling(effect)
        }
        let presenter = PinScreenPresenter(
            useCase: .authenticateBeforeChanging,
            flow: flow,
            interactor: PinInteractor(),
            biometryProvider: BiometryProvider(),
            appSettings: DIKit.resolve(),
            cloudSettings: DIKit.resolve(),
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: DIKit.resolve(tag: "CrashlyticsRecorder"),
            credentialsStore: DIKit.resolve(),
            backwardRouting: backwardRouting,
            forwardRouting: forwardRouting,
            performEffect: effectHandling,
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        let viewController = PinScreenViewController(using: presenter)
        present(viewController: viewController)
    }

    /// Invokes a PIN creation flow in which a user has to select a new PIN -> create a new PIN
    private func create() {
        select()
    }

    /// Selection - Once a new pin needs to be created (change / creation), the user is required to select it.
    private func select(previousPin: Pin? = nil) {
        let useCase = PinScreenUseCase.select(previousPin: previousPin)
        let backwardRouting: PinRouting.RoutingType.Backward = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        let forwardRouting: PinRouting.RoutingType.Forward = { [weak self] input in
            self?.create(pin: input.pin!)
        }
        let effectHandling: PinRouting.RoutingType.Effect = { [weak self] effect in
            self?.effectHandling(effect)
        }
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: PinInteractor(),
            biometryProvider: BiometryProvider(),
            appSettings: DIKit.resolve(),
            cloudSettings: DIKit.resolve(),
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: DIKit.resolve(tag: "CrashlyticsRecorder"),
            credentialsStore: DIKit.resolve(),
            backwardRouting: backwardRouting,
            forwardRouting: forwardRouting,
            performEffect: effectHandling,
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        let viewController = PinScreenViewController(using: presenter)
        present(viewController: viewController)
    }

    /// Creation - after the user has selected a new PIN, he is required to repeat it.
    private func create(pin: Pin) {
        let useCase = PinScreenUseCase.create(firstPin: pin)
        let backwardRouting: PinRouting.RoutingType.Backward = { [weak self] in
            self?.recorder.record("backwardRouting block called")
            // check whether navigation controller is nil or not
            // this is added because of a crash caused by navigationController being nil for some reason
            guard let navController = self?.navigationController else {
                self?.recorder.record("PinRouter navigationController found nil, failing gracefully.")
                return
            }
            navController.popViewController(animated: true)
        }
        let forwardRouting: PinRouting.RoutingType.Forward = { [weak self] _ in
            self?.recorder.record("forwardRouting block called")
            self?.finish()
        }
        let effectHandling: PinRouting.RoutingType.Effect = { [weak self] effect in
            self?.recorder.record("effectHandling block called with type: \(effect)")
            self?.effectHandling(effect)
        }
        let presenter = PinScreenPresenter(
            useCase: useCase,
            flow: flow,
            interactor: PinInteractor(),
            biometryProvider: BiometryProvider(),
            appSettings: DIKit.resolve(),
            cloudSettings: DIKit.resolve(),
            legacyGuidRepository: DIKit.resolve(),
            legacySharedKeyRepository: DIKit.resolve(),
            recorder: DIKit.resolve(tag: "CrashlyticsRecorder"),
            credentialsStore: DIKit.resolve(),
            backwardRouting: backwardRouting,
            forwardRouting: forwardRouting,
            performEffect: effectHandling,
            reachability: Reachability(),
            analyticsRecorder: DIKit.resolve()
        )
        let viewController = PinScreenViewController(using: presenter)
        present(viewController: viewController)
        recorder.record("create(pin:) called")
    }

    /// Handle the display of a new view controller
    private func present(viewController: UIViewController) {
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.delegate = self
            switch flow.origin {
            case .attachedOn(controller: let controller):
                controller.value?.add(child: navigationController)
            case .background:
                // Sets view controller as rootViewController of the window
                guard let keyWindow = UIApplication.shared.firstKeyWindow else {
                    fatalError("keyWindow not found")
                }
                keyWindow.setRootViewController(navigationController)
            case .foreground(parent: let boxedParent):
                if let parent = boxedParent.value {
                    navigationController.modalPresentationStyle = .fullScreen
                    parent.present(navigationController, animated: true)
                } else {
                    recorder.error(PinRouting.FlowError.parentViewControllerNilOnForegroundAuthentication)
                }
            }
            self.navigationController = navigationController
        }
    }

    /// Cleanup the flow and calls completion handler
    private func finish(
        animated: Bool = true,
        performsCompletionAfterDismissal: Bool = true,
        completedSuccessfully: Bool = true,
        completionInput: PinRouting.RoutingType.Input = .none
    ) {
        // Concentrate any cleanup logic here
        let cleanup = { [weak self] in
            guard let self else { return }
            self.navigationController = nil
            self.isBeingDisplayed = false
            if completedSuccessfully, performsCompletionAfterDismissal {
                self.completion?(completionInput)
            }
        }

        // Dismiss the pin flow
        switch flow.origin {
        case .foreground:
            guard let controller = navigationController else {
                // The controller MUST be allocated at that point. report non-fatal in case something goes wrong
                recorder.error(PinRouting.FlowError.navigationControllerIsNotInitialized)
                return
            }
            if completedSuccessfully, !performsCompletionAfterDismissal {
                completion?(completionInput)
            }
            controller.dismiss(animated: animated, completion: cleanup)
        case .background:
            cleanup()
        case .attachedOn:
            cleanup()
        }
    }
}

// MARK: - UINavigationControllerDelegate (Screen routing animation)

extension PinRouter: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        let transition = ScreenTransitioningAnimator.TransitionType.translate(from: operation, duration: 0.4)
        return ScreenTransitioningAnimator(transition: transition)
    }
}
