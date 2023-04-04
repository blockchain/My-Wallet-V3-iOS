// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import PlatformUIKit
import SwiftUI
import UIKit

public final class AuthorizeDeviceViewController: UINavigationController {

    // MARK: - Properties

    private let store: Store<AuthorizeDeviceState, AuthorizeDeviceAction>
    private let viewStore: ViewStore<AuthorizeDeviceState, AuthorizeDeviceAction>
    private let viewDismissed: () -> Void
    private var detailsScreenViewController: DetailsScreenViewController?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup

    public init(
        store: Store<AuthorizeDeviceState, AuthorizeDeviceAction>,
        viewDismissed: @escaping () -> Void
    ) {
        self.store = store
        self.viewDismissed = viewDismissed
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()

        viewStore
            .publisher
            .authorizationResult
            .compactMap { $0 }
            .sink { [weak self] result in
                guard let self else { return }
                showAuthorizationResult(result)
            }
            .store(in: &cancellables)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDismissed()
    }

    override public func viewDidLayoutSubviews() {
        detailsScreenViewController?.view.frame = view.bounds
    }

    // MARK: Methods

    private func setup() {
        setNavigationBarHidden(true, animated: true)
        navigationItem.setHidesBackButton(true, animated: true)
        let presenter = VerifyDeviceDetailsScreenPresenter(
            details: viewStore.loginRequestInfo.details,
            requestTime: viewStore.loginRequestInfo.timestamp,
            didAuthorizeDevice: { [weak self] authorized in
                guard let self else { return }
                viewStore.send(.handleAuthorization(authorized))
            }
        )
        let vc = DetailsScreenViewController(presenter: presenter)
        detailsScreenViewController = vc
        add(child: vc)
    }

    private func showAuthorizationResult(_ result: AuthorizationResult) {
        var viewController: UIHostingController<AuthorizationResultView>
        var view: AuthorizationResultView
        switch result {
        case .success:
            view = .success
        case .linkExpired:
            view = .linkExpired
        case .requestDenied:
            view = .rejected
        case .unknown:
            view = .unknown
        }
        view.okButtonPressed = {
            self.dismiss(animated: true, completion: nil)
        }
        viewController = UIHostingController(rootView: view)
        pushViewController(viewController, animated: true)
        detailsScreenViewController = nil
    }
}
