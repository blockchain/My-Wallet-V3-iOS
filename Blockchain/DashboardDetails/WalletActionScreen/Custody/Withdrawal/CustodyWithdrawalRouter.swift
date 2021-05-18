//
//  CustodyWithdrawalRouter.swift
//  Blockchain
//
//  Created by AlexM on 2/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
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
    private let dataProviding: DataProviding
    private let navigationRouter: NavigationRouterAPI
    private let webViewService: WebViewServiceAPI
    private let internalFeatureService: InternalFeatureFlagServiceAPI
    private let featureConfiguring: FeatureConfiguring
    private var currency: CryptoCurrency!
    private let disposeBag = DisposeBag()
    
    init(navigationRouter: NavigationRouterAPI = NavigationRouter(),
         dataProviding: DataProviding = DataProvider.default,
         webViewService: WebViewServiceAPI = resolve(),
         featureConfiguring: FeatureConfiguring = resolve(),
         internalFeatureService: InternalFeatureFlagServiceAPI = resolve()) {
        self.featureConfiguring = featureConfiguring
        self.internalFeatureService = internalFeatureService
        self.dataProviding = dataProviding
        self.navigationRouter = navigationRouter
        self.webViewService = webViewService
    }
    
    func start(with currency: CryptoCurrency) {
        self.currency = currency
        self.stateService = CustodyWithdrawalStateService()
        
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
        case .summary:
            showSummaryScreen()
        case .end:
            navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                self.completionRelay.accept(())
            })
        case .webview(let url):
            if let topMostViewController = navigationRouter.topMostViewControllerProvider.topMostViewController {
                webViewService.openSafari(url: url, from: topMostViewController)
            }
        }
    }
    
    private func showWithdrawalScreen() {
        if featureConfiguring.configuration(for: .internalSendEnabled).isEnabled {
            internalSendRelay.accept(())
        } else {
            let interactor = CustodyWithdrawalScreenInteractor(
                currency: currency,
                balanceFetching: dataProviding.balance[currency.currency],
                accountRepository: AssetAccountRepository.shared
            )
            let presenter = CustodyWithdrawalScreenPresenter(
                interactor: interactor,
                currency: currency,
                stateService: stateService
            )
            let controller = CustodyWithdrawalViewController(presenter: presenter)
            if #available(iOS 13.0, *) {
                controller.isModalInPresentation = true
            }
            navigationRouter.present(viewController: controller, using: .modalOverTopMost)
        }
    }
    
    private func showSummaryScreen() {
        let presenter = CustodyWithdrawalSummaryPresenter(
            status: stateService.completionRelay.value,
            currency: currency,
            stateService: stateService
        )
        let controller = CustodyWithdrawalSummaryViewController(presenter: presenter)
        navigationRouter.present(viewController: controller)
    }
    
    func previous() {
        navigationRouter.dismiss()
    }
}
