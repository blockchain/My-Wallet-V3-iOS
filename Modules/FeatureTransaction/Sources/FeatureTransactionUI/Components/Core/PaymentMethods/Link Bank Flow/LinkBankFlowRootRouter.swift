// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import PlatformKit
import RIBs
import RxCocoa
import RxSwift
import SwiftUI
import SystemConfiguration
import UIComponentsKit

/// Represents an effect as part of the LinkBank Flow
public enum LinkBankFlowEffect: Equatable {
    /// Bank is linked
    case bankLinked
    /// Close of the flow should occur,
    /// `true` if the close event occured from a "pull down" to close event, otherwise `false`
    case closeFlow(_ isInteractive: Bool)

    /// Helper variable to check if self is `closeFlow`
    public var isCloseEffect: Bool {
        guard case .closeFlow = self else {
            return false
        }
        return true
    }

    /// Returns `true` if the given effect should be
    /// skipped as part of the flow output, otherwise `false`
    public var shouldSkipEffect: Bool {
        switch self {
        case .closeFlow:
            return false
        case .bankLinked:
            return true
        }
    }
}

public protocol LinkBankFlowStarter: AnyObject {
    /// Helper method for starting the withdraw flow
    func startFlow() -> Observable<LinkBankFlowEffect>
}

public protocol StartOpenBanking {

    func link(
        account data: BankLinkageData,
        currency: FiatCurrency,
        listener: LinkBankListener
    ) -> UIViewController
}

protocol LinkBankFlowRootInteractable: Interactable,
    LinkBankSplashScreenListener,
    LinkBankListener,
    LinkBankFailureScreenListener
{
    var linkBankFlowEffect: Observable<LinkBankFlowEffect> { get }
    var router: LinkBankFlowRootRouting? { get set }
}

final class LinkBankFlowRootRouter: RIBs.Router<LinkBankFlowRootInteractable>,
    LinkBankFlowStarter,
    LinkBankFlowRootRouting
{

    private var dismissFlow: (() -> Void)?

    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private var presentingController: UIViewController? {
        topMostViewControllerProvider.topMostViewController
    }

    private let app: AppProtocol
    private let splashScreenBuilder: LinkBankSplashScreenBuildable
    private let yodleeScreenBuilder: YodleeScreenBuildable
    private let failureScreenBuilder: LinkBankFailureScreenBuildable
    private let startOpenBanking: StartOpenBanking

    private var navigationController: UINavigationController?

    init(
        app: AppProtocol = resolve(),
        interactor: LinkBankFlowRootInteractable,
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        splashScreenBuilder: LinkBankSplashScreenBuildable,
        yodleeScreenBuilder: YodleeScreenBuildable,
        failureScreenBuilder: LinkBankFailureScreenBuildable,
        startOpenBanking: StartOpenBanking = resolve()
    ) {
        self.app = app
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.splashScreenBuilder = splashScreenBuilder
        self.yodleeScreenBuilder = yodleeScreenBuilder
        self.failureScreenBuilder = failureScreenBuilder
        self.startOpenBanking = startOpenBanking
        super.init(interactor: interactor)
        interactor.router = self
    }

    func route(to screen: LinkBankFlow.Screen) {
        switch screen {
        case .splash(let data):
            detachCurrentChild() // in case of a failure we need to detatch the current child
            let router = splashScreenBuilder.build(withListener: interactor, data: data)
            attachChild(router)
            let navigationController = UINavigationController(
                rootViewController: router.viewControllable.uiviewController
            )
            presentingController?.present(navigationController, animated: true, completion: nil)
            self.navigationController = navigationController
        case .yodlee(let data):
            let router = yodleeScreenBuilder.build(withListener: interactor, data: data)
            attachChild(router)
            navigationController?.pushViewController(router.viewControllable.uiviewController, animated: true)
            app.post(event: blockchain.ux.transaction.payment.method.link.a.bank.via.ACH)
        case .yapily(let data):
            detachCurrentChild()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, app] in
                guard let self else { return }
                presentingController?.present(
                    startOpenBanking.link(
                        account: data,
                        currency: data.currency,
                        listener: interactor
                    ),
                    animated: true
                )
                app.post(event: blockchain.ux.transaction.payment.method.link.a.bank.via.OpenBanking)
            }
        case .failure:
            let router = failureScreenBuilder.build(withListener: interactor)
            attachChild(router)
            presentingController?.present(router.viewControllable.uiviewController, animated: true, completion: nil)
        }
    }

    func closeFailureScreen() {
        detachCurrentChild()
        presentingController?.dismiss(animated: true, completion: nil)
    }

    func returnToSplashScreen() {
        detachCurrentChild()
        navigationController?.popViewController(animated: true)
    }

    func closeFlow(isInteractive: Bool) {
        // no-op, will be handled by `linkBankFlowEffect` stream
    }

    // MARK: - LinkBankFlowStarter

    func startFlow() -> Observable<LinkBankFlowEffect> {
        interactable.activate()
        load()
        return interactor.linkBankFlowEffect
    }

    // MARK: - Private methods

    func detachCurrentChild() {
        guard let currentRouter = children.last else {
            return
        }
        detachChild(currentRouter)
    }
}
