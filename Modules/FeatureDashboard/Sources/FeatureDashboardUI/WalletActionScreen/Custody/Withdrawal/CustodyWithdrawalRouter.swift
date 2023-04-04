// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

protocol CustodyWithdrawalRouterAPI: AnyObject {
    func next(to state: CustodyWithdrawalStateService.State)
    func previous()
    func start(with currency: CryptoCurrency)

    var completionRelay: PublishRelay<Void> { get }
    var internalSendRelay: PublishRelay<Void> { get }
}

final class CustodyWithdrawalRouter: CustodyWithdrawalRouterAPI {

    // MARK: - `Router` Properties

    let completionRelay = PublishRelay<Void>()
    let internalSendRelay = PublishRelay<Void>()

    private var stateService: CustodyWithdrawalStateService!
    private let navigationRouter: NavigationRouterAPI
    private var currency: CryptoCurrency!
    private let disposeBag = DisposeBag()

    init(navigationRouter: NavigationRouterAPI = NavigationRouter()) {
        self.navigationRouter = navigationRouter
    }

    func start(with currency: CryptoCurrency) {
        self.currency = currency
        stateService = CustodyWithdrawalStateService()

        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                case .dismiss:
                    self.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }

    func next(to state: CustodyWithdrawalStateService.State) {
        switch state {
        case .start:
            break
        case .withdrawal:
            showWithdrawalScreen()
        case .end:
            navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: { [weak self] in
                guard let self else { return }
                completionRelay.accept(())
            })
        }
    }

    private func showWithdrawalScreen() {
        internalSendRelay.accept(())
    }

    func previous() {
        navigationRouter.dismiss()
    }
}
