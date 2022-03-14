// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

public protocol NonCustodialActionRouterAPI: AnyObject {
    func next(to state: NonCustodialActionState)
    func start(with account: BlockchainAccount)
}

public final class NonCustodialActionRouter: NonCustodialActionRouterAPI {

    // MARK: - `Router` Properties

    private var stateService: NonCustodialActionStateService!
    private let walletOperationsRouter: WalletOperationsRouting
    private let navigationRouter: NavigationRouterAPI
    private let routing: TabSwapping
    private var disposeBag = DisposeBag()
    private var account: BlockchainAccount!

    public init(
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        walletOperationsRouter: WalletOperationsRouting = resolve(),
        routing: TabSwapping
    ) {
        self.walletOperationsRouter = walletOperationsRouter
        self.navigationRouter = navigationRouter
        self.routing = routing
    }

    public func start(with account: BlockchainAccount) {
        // TODO: Would much prefer a different form of injection
        // but we build our `Routers` in the AppCoordinator
        disposeBag = DisposeBag()
        self.account = account
        stateService = NonCustodialActionStateService()

        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous, .dismiss:
                    break
                case .next(let state):
                    self.next(to: state)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }

    public func next(to state: NonCustodialActionState) {
        /// Dismiss the `WalletScreenActionViewController`
        switch state {
        case .actions:
            showNonCustodialActionScreen()
        case .swap:
            showSwapScreen()
        case .activity:
            showActivityScreen()
        case .send:
            showSendScreen()
        case .receive:
            showReceiveScreen()
        case .buy:
            showBuyScreen()
        case .sell:
            showSellScreen()
        }
    }

    private func showNonCustodialActionScreen() {
        let interactor = WalletActionScreenInteractor(account: account)
        let presenter = NonCustodialActionScreenPresenter(using: interactor, stateService: stateService)
        let controller = WalletActionScreenViewController(using: presenter)
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        navigationRouter.topMostViewControllerProvider.topMostViewController?.present(controller, animated: true, completion: nil)
    }

    private func showSwapScreen() {
        dismiss { [routing] _ in
            routing.switchTabToSwap()
        }
    }

    private func showActivityScreen() {
        dismiss { [routing] account in
            routing.switchToActivity(for: account.currencyType)
        }
    }

    private func showReceiveScreen() {
        dismiss { [routing] account in
            routing.receive(into: account)
        }
    }

    private func showBuyScreen() {
        dismiss { [walletOperationsRouter] account in
            walletOperationsRouter.handleBuyCrypto(account: account as? CryptoAccount)
        }
    }

    private func showSellScreen() {
        dismiss { [walletOperationsRouter] account in
            walletOperationsRouter.handleSellCrypto(account: account as? CryptoAccount)
        }
    }

    private func showSendScreen() {
        dismiss { [routing] account in
            routing.send(from: account)
        }
    }

    /// Dismiss all presented ViewControllers and then execute callback.
    private func dismiss(completion: ((BlockchainAccount) -> Void)? = nil) {
        let account: BlockchainAccount = account
        var root: UIViewController? = navigationRouter.topMostViewControllerProvider.topMostViewController
        while root?.presentingViewController != nil {
            root = root?.presentingViewController
        }
        root?
            .dismiss(
                animated: true,
                completion: {
                    completion?(account)
                }
            )
    }

    private lazy var sheetPresenter: BottomSheetPresenting = BottomSheetPresenting(ignoresBackgroundTouches: false)
}
