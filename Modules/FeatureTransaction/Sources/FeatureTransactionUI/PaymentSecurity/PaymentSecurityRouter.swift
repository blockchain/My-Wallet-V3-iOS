// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureCardPaymentDomain
import PlatformKit
import PlatformUIKit
import UIKit

enum PaymentSecurityFlowResult {
    case abandoned
    case completed
    case pending
    case failed
}

final class PaymentSecurityRouter {

    private var stripeClient: StripeUIClientAPI
    private let routingInteractor: CardRouterInteractor
    private var cancellables = Set<AnyCancellable>()

    init(
        routingInteractor: CardRouterInteractor = .init(),
        stripeClient: StripeUIClientAPI = resolve(),
        completion: @escaping (PaymentSecurityFlowResult) -> Void
    ) {
        self.routingInteractor = routingInteractor
        self.stripeClient = stripeClient
        routingInteractor
            .cancellation
            .asPublisher()
            .map { _ in PaymentSecurityFlowResult.abandoned }
            .replaceError(with: PaymentSecurityFlowResult.failed)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &cancellables)

        routingInteractor
            .pending
            .asPublisher()
            .map { _ in PaymentSecurityFlowResult.pending }
            .replaceError(with: PaymentSecurityFlowResult.failed)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &cancellables)

        routingInteractor
            .completionCardData
            .asPublisher()
            .map { _ in PaymentSecurityFlowResult.completed }
            .replaceError(with: PaymentSecurityFlowResult.failed)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }

    func presentPaymentSecurity(from presentingVC: UIViewController, authorizationData: PartnerAuthorizationData) {
        let interactor = CardAuthorizationScreenInteractor(
            routingInteractor: routingInteractor
        )
        let presenter = CardAuthorizationScreenPresenter(
            interactor: interactor,
            data: authorizationData
        )

        guard case .required(let params) = authorizationData.state else {
            presenter.redirect()
            return
        }

        switch params.cardAcquirer {
        case .stripe:
            stripeClient.confirmPayment(authorizationData, with: presenter)
        case .everyPay, .checkout, .fake:
            let viewController = CardAuthorizationScreenViewController(
                presenter: presenter
            )
            presentingVC.present(viewController, animated: true, completion: nil)
        case .unknown:
            presenter.redirect()
        }
    }
}
