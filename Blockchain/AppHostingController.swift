// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
import WalletConnectSwift

protocol LoggedInViewController: UIViewController, LoggedInBridge {
    init(store: Store<LoggedIn.State, LoggedIn.Action>, siteMap: SiteMap)
    func clear()
}

extension RootViewController: LoggedInViewController {}

/// Acts as the main controller for onboarding and logged in states
final class AppHostingController: UIViewController {
    let store: Store<CoreAppState, CoreAppAction>
    let viewStore: ViewStore<CoreAppState, CoreAppAction>

    private let siteMap: SiteMap

    private weak var alertController: UIAlertController?

    private var onboardingController: OnboardingHostingController?
    private var loggedInController: RootViewController?
    private var multiAppController: SuperAppRootControllable?
    private var loggedInDependencyBridge: LoggedInDependencyBridgeAPI
    private var featureFlagsService: FeatureFlagsServiceAPI

    private var dynamicBridge: DynamicDependencyBridge = .init()

    private var cancellables: Set<AnyCancellable> = []

    init(
        store: Store<CoreAppState, CoreAppAction>,
        loggedInDependencyBridge: LoggedInDependencyBridgeAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
        self.loggedInDependencyBridge = loggedInDependencyBridge
        self.featureFlagsService = featureFlagsService
        self.siteMap = SiteMap(app: app)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.0431372549, green: 0.1019607843, blue: 0.2784313725, alpha: 1)

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
                let shownViewController = self.loggedInController ?? self.multiAppController
                if let shownViewController {
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
                self.loggedInController?.clear()
                self.loggedInController = nil
                self.multiAppController?.clear()
                self.multiAppController = nil
            })
            .store(in: &cancellables)

        store
            .scope(state: \.loggedIn, action: CoreAppAction.loggedIn)
            .ifLet(then: { [weak self] store in
                guard let self else { return }

                func load(_ loggedInController: RootViewController) {
                    // this is important, register the controller as a bridge
                    // for many places throughout the app
                    self.dynamicBridge.register(bridge: loggedInController)
                    loggedInController.view.frame = self.view.bounds
                    if let onboardingController = self.onboardingController {
                        self.transition(
                            from: onboardingController,
                            to: loggedInController,
                            animate: true
                        )
                    } else {
                        self.add(child: loggedInController)
                    }
                    self.loggedInController = loggedInController
                    self.onboardingController = nil
                    self.multiAppController = nil
                }

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
                    self.loggedInController = nil
                    self.onboardingController = nil
                }

                if #available(iOS 15, *) {
                    app.publisher(for: blockchain.app.configuration.app.superapp.v1.is.enabled, as: Bool.self)
                        .receive(on: DispatchQueue.main)
                        .sink { [app] isMultiAppEnabled in
                            guard let value = isMultiAppEnabled.value else {
                                return load(RootViewController(store: store, siteMap: self.siteMap))
                            }
                            if value {
                                loadMultiApp(SuperAppRootController(store: store, app: app, siteMap: self.siteMap))
                            } else {
                                load(RootViewController(store: store, siteMap: self.siteMap))
                            }
                        }
                        .store(in: &self.cancellables)
                } else {
                    load(RootViewController(store: store, siteMap: self.siteMap))
                }
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
        let loggedInController = loggedInController ?? multiAppController
        return loggedInController ?? onboardingController
    }

    override public var childForStatusBarStyle: UIViewController? { currentController }
    override public var childForStatusBarHidden: UIViewController? { currentController }
    override public var childForHomeIndicatorAutoHidden: UIViewController? { currentController }
    override public var childForScreenEdgesDeferringSystemGestures: UIViewController? { currentController }
    override public var childViewControllerForPointerLock: UIViewController? { currentController }
}
