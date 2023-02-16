// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureAppUI
import FeaturePin
import ToolKit
import UIKit

/// Acts as a container for `PinRouter` wireframing actions
final class PinHostingController: UIViewController {

    let store: Store<PinCore.State, PinCore.Action>
    let viewStore: ViewStore<PinCore.State, PinCore.Action>

    private var cancellables: Set<AnyCancellable> = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private var pinRouter: PinRouter?

    init(store: Store<PinCore.State, PinCore.Action>) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewStore.publisher.creating
            .filter { $0 }
            .sink { [weak self] _ in
                self?.createPin()
            }
            .store(in: &cancellables)

        viewStore.publisher.authenticate
            .filter { $0 }
            .sink { [weak self] _ in
                self?.authenticatePin()
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        app.post(event: blockchain.ux.user.authentication.sign.in.enter.pin)
    }

    /// Authenticate using a pin code. Used during login when the app enters active state.
    private func authenticatePin() {
        // If already authenticating, skip this as the screen is already presented
        guard pinRouter == nil || !(pinRouter?.isDisplayingLoginAuthentication ?? false) else {
            return
        }
        let logout: PinRouting.RoutingType.Logout = { [viewStore] in
            viewStore.send(.logout)
        }
        let flow = PinRouting.Flow.authenticate(
            from: .attachedOn(controller: UnretainedContentBox<UIViewController>(self)),
            logoutRouting: logout
        )
        pinRouter = PinRouter(flow: flow) { [weak self] input in
            guard let password = input.password else { return }
            self?.viewStore.send(.handleAuthentication(password))
        }
        pinRouter?.execute()
    }

    /// Create a new pin code. Used during onboarding, when the user is required to define a pin code before entering his wallet.
    func createPin() {
        let boxedParent = UnretainedContentBox<UIViewController>(self)
        let flow = PinRouting.Flow.createPin(from: .attachedOn(controller: boxedParent))
        pinRouter = PinRouter(flow: flow) { [weak self] _ in
            guard let self else { return }
            self.viewStore.send(.pinCreated)
        }
        pinRouter?.execute()
    }

    private func logout() {
        viewStore.send(.logout)
    }
}
