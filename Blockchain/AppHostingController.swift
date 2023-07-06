// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftformat:disable redundantSelf

import Combine
import ComposableArchitecture
import DIKit
import FeatureAppUI
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import MoneyKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit
import UIKit

/// Acts as the main controller for onboarding and logged in states
final class AppHostingController: UIViewController {
    let store: Store<CoreAppState, CoreAppAction>
    let viewStore: ViewStore<CoreAppState, CoreAppAction>

    private let siteMap: SiteMap

    private weak var alertController: UIAlertController?

    private var onboardingController: OnboardingHostingController?
    private var multiAppController: SuperAppRootControllable?
    private var loggedInDependencyBridge: LoggedInDependencyBridgeAPI

    private var dynamicBridge: DynamicDependencyBridge = .init()

    private var cancellables: Set<AnyCancellable> = []

    init(
        store: Store<CoreAppState, CoreAppAction>,
        loggedInDependencyBridge: LoggedInDependencyBridgeAPI = resolve()
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
        self.loggedInDependencyBridge = loggedInDependencyBridge
        self.siteMap = SiteMap(app: app)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.semantic.light

        loggedInDependencyBridge
            .register(bridge: dynamicBridge)

        viewStore.publisher
            .alertState
            .sink { [weak self] alert in
                guard let self else {
                    return
                }
                if let alert {
                    let alertController = UIAlertController(
                        state: alert,
                        send: { action in
                            if let action {
                                self.viewStore.send(action)
                            }
                        }
                    )
                    self.present(alertController, animated: true, completion: nil)
                    self.alertController = alertController
                } else {
                    self.alertController?.dismiss(animated: true, completion: nil)
                    self.alertController = nil
                }
            }
            .store(in: &cancellables)

        store
            .scope(state: \.onboarding, action: CoreAppAction.onboarding)
            .ifLet(then: { [weak self] onboardingStore in
                guard let self else { return }
                let onboardingController = OnboardingHostingController(store: onboardingStore)
                if let shownViewController = self.multiAppController {
                    self.transition(
                        from: shownViewController,
                        to: onboardingController,
                        animate: true
                    )
                } else {
                    self.add(child: onboardingController)
                }
                self.onboardingController = onboardingController
                self.dynamicBridge.register(bridge: SignedOutDependencyBridge())
                self.multiAppController?.clear()
                self.multiAppController = nil
            })
            .store(in: &cancellables)

        store
            .scope(state: \.loggedIn, action: CoreAppAction.loggedIn)
            .ifLet(then: { [weak self] store in
                guard let self else { return }

                func loadMultiApp(_ controller: SuperAppRootControllableLoggedInBridge) {
                    controller.view.frame = self.view.bounds
                    self.dynamicBridge.register(bridge: controller)
                    if let onboardingController = self.onboardingController {
                        self.transition(
                            from: onboardingController,
                            to: controller,
                            animate: true
                        )
                    } else {
                        self.add(child: controller)
                    }
                    self.multiAppController = controller
                    self.onboardingController = nil
                }

                loadMultiApp(SuperAppRootController(store: store, app: app, siteMap: self.siteMap))
            })
            .store(in: &cancellables)

        store
            .scope(state: \.deviceAuthorization, action: CoreAppAction.authorizeDevice)
            .ifLet(then: { [weak self] authorizeDeviceScope in
                guard let self else { return }
                let nav = AuthorizeDeviceViewController(
                    store: authorizeDeviceScope,
                    viewDismissed: { [weak self] in
                        self?.viewStore.send(.deviceAuthorizationFinished)
                    }
                )
                self.topMostViewController?.present(nav, animated: true, completion: nil)
            })
            .store(in: &cancellables)
    }
}

extension AppHostingController {

    private var currentController: UIViewController? {
        multiAppController ?? onboardingController
    }

    override public var childForStatusBarStyle: UIViewController? { currentController }
    override public var childForStatusBarHidden: UIViewController? { currentController }
    override public var childForHomeIndicatorAutoHidden: UIViewController? { currentController }
    override public var childForScreenEdgesDeferringSystemGestures: UIViewController? { currentController }
    override public var childViewControllerForPointerLock: UIViewController? { currentController }
}
