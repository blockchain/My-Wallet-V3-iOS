// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureCardPaymentData
import FeatureCardPaymentDomain
import FeatureVGSData
import PlatformKit
import RxSwift
import SwiftUI
import UIComponentsKit
import UIKit

public final class VGSAddCardObserver: Client.Observer {
    unowned let app: AppProtocol
    private let topViewController: TopMostViewControllerProviding

    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        topViewController: TopMostViewControllerProviding = DIKit.resolve()
    ) {
        self.app = app
        self.topViewController = topViewController
    }

    var observers: [AnyCancellable] {
        [
            onAddCard,
            onNeedCvv
        ]
    }

    public func start() {
        for observer in observers {
            observer.store(in: &cancellables)
        }
    }

    public func stop() {
        cancellables = []
    }

    private lazy var onAddCard = app.on(
        blockchain.ux.payment.method.vgs.add.card
    )
    .receive(on: DispatchQueue.main)
    .sink(to: VGSAddCardObserver.handleAddCard(_:), on: self)

    private lazy var onNeedCvv = app.on(
        blockchain.ux.payment.method.vgs.cvv.is.required
    )
    .receive(on: DispatchQueue.main)
    .sink(to: VGSAddCardObserver.handleNeedCvv(_:), on: self)

    private func handleAddCard(_ event: Session.Event) {
        let vgsClient: VGSClientAPI = DIKit.resolve()
        let cardClient: CardDetailClientAPI = DIKit.resolve()
        let activationService: PaymentMethodTypesServiceAPI = DIKit.resolve()
        let cardSuccessRateService: CardSuccessRateServiceAPI = DIKit.resolve()

        let fetchCards = { id in
            activationService.fetchCardsPublisher(andPrefer: id)
        }

        let environment = VGSEnvironment(
            retrieveCardTokenId: vgsClient.getCardTokenId,
            waitForActivationOfCard: cardClient.getCard(by:),
            fetchCardsAndPreferId: fetchCards,
            cardSuccessRateService: cardSuccessRateService.getCardSuccessRate(binNumber:)
        )
        let content = VGSContentView(
            environment: environment,
            completeBlock: { [app] cardPayload in
                app.post(
                    event: blockchain.ux.payment.method.vgs.add.card.completed,
                    context: [blockchain.ux.payment.method.vgs.add.card.completed.card.data: cardPayload]
                )
            },
            dismissBlock: { [app] in
                app.post(
                    event: blockchain.ux.payment.method.vgs.add.card.abandoned
                )
            }
        )

        presentView(content.app(app))
    }

    private func handleNeedCvv(_ event: Session.Event) {
        let paymentId = try? event.context.decode(
            blockchain.ux.payment.method.vgs.cvv.is.required.payment.id,
            as: String.self
        )
        let paymentMethodId = try? event.context.decode(
            blockchain.ux.payment.method.vgs.cvv.is.required.payment.method.id,
            as: String.self
        )
        guard let paymentId, let paymentMethodId else {
            "❗️missing context information".peek()
            return
        }
        let content = CVVView(
            vgsClient: DIKit.resolve(),
            cardRepository: DIKit.resolve(),
            paymentId: paymentId,
            paymentMethodId: paymentMethodId,
            dismissBlock: { [topViewController] in
                topViewController.topMostViewController?.dismiss(animated: true)
            }
        )

        presentView(content.app(app))
    }

    private func presentView<Content: View>(_ rootView: Content) {
        let presentingViewController = topViewController.topMostViewController

        // New VGS Add Card
        let viewController = UIHostingController(
            rootView: rootView
        )

        viewController.isModalInPresentation = true
        presentingViewController?.present(viewController, animated: true)
    }
}
