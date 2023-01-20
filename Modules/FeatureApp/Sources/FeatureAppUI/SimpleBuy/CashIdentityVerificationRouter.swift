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
