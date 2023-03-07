// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import UIComponentsKit

public protocol CashIdentityVerificationRouterAPI {
    func dismiss(startKYC: Bool)
}

extension CashIdentityVerificationRouterAPI {
    public func dismiss() {
        dismiss(startKYC: false)
    }
}

final class SuperAppCashIdentityVerificationRouter: CashIdentityVerificationRouterAPI {

    private weak var viewController: UIViewController?
    private let kycRouter: KYCRouterAPI

    init(controller: UIViewController, kycRouter: KYCRouterAPI = resolve()) {
        self.viewController = controller
        self.kycRouter = kycRouter
    }

    func dismiss(startKYC: Bool) {
        let kycRouter = kycRouter
        viewController?.dismiss(animated: true) {
            guard startKYC else { return }
            kycRouter.start(parentFlow: .cash)
        }
    }
}

final class CashIdentityVerificationRouter: CashIdentityVerificationRouterAPI {

    private weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    private let kycRouter: KYCRouterAPI

    init(
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        kycRouter: KYCRouterAPI = resolve()
    ) {
        self.kycRouter = kycRouter
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }

    func dismiss(startKYC: Bool) {
        let kycRouter = kycRouter
        topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: {
            guard startKYC else { return }
            kycRouter.start(parentFlow: .cash)
        })
    }
}
