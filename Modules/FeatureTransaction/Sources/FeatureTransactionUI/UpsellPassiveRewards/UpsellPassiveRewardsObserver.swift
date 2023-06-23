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
                    let validCryptos = ["BTC","ETH","USDT","USDC","DAI","PAX"]

//                    let validCryptos = (try? await app.get(blockchain.app.configuration.upsell.passive.rewards.after.swap, as: [String].self))  ?? []

                    for await (
                        date,
                        currency,
                        isPrivateKey
                    ) in
                            combineLatest(
                        app.stream(blockchain.ux.upsell.after.successful.swap.maybe.later.timestamp, as: Date.self),
                        app.stream(blockchain.ux.transaction.source.target.id, as: CryptoCurrency.self),
                        app.stream(blockchain.ux.transaction.source.is.private.key, as: Bool.self)
                    ) {

                        guard let currencyCode = currency.value?.code else {
                            return
                        }

                        let isEligible = try await app.get(blockchain.user.earn.product["savings"].asset[currencyCode].is.eligible, as: Bool.self)
                        print("💸\(isEligible)")
                        let shouldLaunchUpsell = isPrivateKey.value == false
                        &&  validCryptos.contains(currencyCode)
                        && date.value.map { Calendar.current.numberOfDaysBetween($0, and: Date()) > 30} ?? true
                        && isEligible

                        try await app.set(blockchain.ux.upsell.after.successful.swap.entry.policy.perform.if,
                                          to: shouldLaunchUpsell)

                    }
                }
                group.addTask {
                    for await _ in app.on(blockchain.ux.transaction["swap"].event.did.finish) {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            app.post(event: blockchain.ux.upsell.after.successful.swap.entry)
//                        }
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

