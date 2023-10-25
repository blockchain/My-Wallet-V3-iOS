// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCardPaymentDomain
import StripePayments
import UIComponentsKit
import UIKit

class StripeUIClient: NSObject, StripeUIClientAPI {
    private static let returnURL = "blockchain://stripe/return"
    private weak var presentingVC: UIViewController?

    func confirmPayment(
        _ data: PartnerAuthorizationData,
        with presenter: CardAuthorizationScreenPresenterAPI
    ) {
        guard case .required(let params) = data.state,
              params.cardAcquirer == .stripe,
              let publishableApiKey = params.publishableApiKey,
              let clientSecret = params.clientSecret,
              let presentingVC = UIApplication.shared.topMostViewController
        else {
            presenter.redirect()
            return
        }

        self.presentingVC = presentingVC

        let handler = STPPaymentHandler.shared()
        handler.apiClient = STPAPIClient(publishableKey: publishableApiKey)
        handler.confirmPayment(STPPaymentIntentParams(clientSecret: clientSecret), with: self) { _, _, _ in
            presenter.redirect()
        }
    }
}

extension StripeUIClient: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        presentingVC!
    }
}
