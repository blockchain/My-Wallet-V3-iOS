//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Foundation
import SwiftUI
import UIComponentsKit
import UIKit
import MoneyKit
import AsyncAlgorithms

public final class UpsellPassiveRewardsObserver: Client.Observer {
    let app: AppProtocol

    public init(app: AppProtocol) {
        self.app = app
    }

    var task: Task<Void, Error>?

    public func start() {
        task = Task {
            try await app.set(blockchain.ux.upsell.after.successful.swap.entry.then.enter.into, to: blockchain.ux.upsell.after.successful.swap)
            try await withThrowingTaskGroup(of: Void.self) { [app] group in
                group.addTask {
                    for await status in app.stream(blockchain.ux.transaction.execution.status, as: Tag.self) {
                        guard let value = status.value else { continue }
                        try await app.set(blockchain.ux.upsell.after.successful.swap.entry.policy.discard.if, to: value != blockchain.ux.transaction.event.execution.status.completed[])
                    }
                }

                group.addTask {
                    for await date in app.stream(blockchain.ux.buy.another.asset.maybe.later.timestamp, as: Date.self) {
                        try await app.set(blockchain.ux.upsell.after.successful.swap.entry.policy.perform.if, to: date.value.map { Calendar.current.numberOfDaysBetween($0, and: Date()) > 30 } ?? true)
                    }
                }

                group.addTask {
                    for await _ in app.on(blockchain.ux.transaction["swap"].event.did.finish) {
                        let targetCrypto = try await app.get(blockchain.ux.transaction.source.target.id, as: CryptoCurrency.self)
                        let isPrivateKey = try await app.get(blockchain.ux.transaction.source.is.private.key, as: Bool.self)

                        let validCryptos = (try? await app.get(blockchain.app.configuration.upsell.passive.rewards.after.swap, as: String.self))  ?? ""
                        let isEligible = try await app.get(blockchain.user.earn.product["savings"].asset[targetCrypto.code].is.eligible, as: Bool.self)


                        let shouldLaunchUpsell = isPrivateKey == false
                        &&  validCryptos.contains(targetCrypto.code)
                        && isEligible


                        if shouldLaunchUpsell {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                app.post(event: blockchain.ux.upsell.after.successful.swap.entry)

                            }

                        }
                    }
                }

                try await group.waitForAll()
            }
        }
    }

    public func stop() { task?.cancel() }
}

extension Calendar {
    fileprivate func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        return numberOfDays.day!
    }
}

