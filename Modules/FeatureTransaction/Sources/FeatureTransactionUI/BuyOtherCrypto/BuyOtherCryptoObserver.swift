// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Foundation
import SwiftUI
import UIComponentsKit
import UIKit

public final class BuyOtherCryptoObserver: Client.Observer {
    let app: AppProtocol
    private let topViewController: TopMostViewControllerProviding
    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        topViewController: TopMostViewControllerProviding = DIKit.resolve()
    ) {
        self.app = app
        self.topViewController = topViewController
    }

    var observers: [BlockchainEventSubscription] {
        [
            transactionDidFinishWithSuccess
        ]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    lazy var transactionDidFinishWithSuccess = app.on(blockchain.ux.transaction["buy"].event.did.finish, blockchain.ux.transaction["sell"].event.did.finish) { [weak self] _ in
        guard let self else { return }
        var executionStatus = try? await app.get(blockchain.ux.transaction.execution.status, as: Tag.self)
        guard let executionStatus, executionStatus == blockchain.ux.transaction.event.execution.status.completed else {
            return
        }

        guard let date = try? await app.get(blockchain.ux.buy.another.asset.maybe.later.timestamp, as: Date.self) else {
            Task {
                await self.presentBuyOtherCryptoView()
            }
            return
        }

        if Calendar.current.numberOfDaysBetween(date, and: Date()) <= 30 {
            return
        }

        Task {
            await self.presentBuyOtherCryptoView()
        }
    }

    @MainActor
    private func presentBuyOtherCryptoView() {
            let presentingViewController = topViewController.topMostViewController
            let view = BuyOtherCryptoView().app(app)
                    let hostedViewController = UIHostingController(rootView: view)
                    hostedViewController.isModalInPresentation = true
                    presentingViewController?.present(hostedViewController, animated: true)
    }
}

extension Calendar {
    fileprivate func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)

        return numberOfDays.day!
    }
}
