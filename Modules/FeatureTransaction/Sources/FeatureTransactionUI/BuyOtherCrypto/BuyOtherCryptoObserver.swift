// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Foundation
import SwiftUI
import UIComponentsKit
import UIKit
import MoneyKit
import AsyncAlgorithms

public final class BuyOtherCryptoObserver: Client.Observer {

    let app: AppProtocol

    public init(app: AppProtocol) {
        self.app = app
    }

    var task: Task<Void, Error>?

    public func start() {
        task = Task {
            try await app.set(blockchain.ux.buy.another.asset.entry.then.enter.into, to: blockchain.ux.buy.another.asset)
            try await withThrowingTaskGroup(of: Void.self) { [app] group in
                group.addTask {
                    for await status in app.stream(blockchain.ux.transaction.execution.status, as: Tag.self) {
                        guard let value = status.value else { continue }
                        try await app.set(blockchain.ux.buy.another.asset.entry.policy.discard.if, to: value != blockchain.ux.transaction.event.execution.status.completed[])
                    }
                }
                group.addTask {
                    for await date in app.stream(blockchain.ux.buy.another.asset.maybe.later.timestamp, as: Date.self) {
                        try await app.set(blockchain.ux.buy.another.asset.entry.policy.perform.if, to: date.value.map { Calendar.current.numberOfDaysBetween($0, and: Date()) > 30 } ?? true)
                    }
                }
                group.addTask {
                    for await _ in app.on(blockchain.ux.transaction["buy"].event.did.finish) {
                        app.post(event: blockchain.ux.buy.another.asset.entry)
                    }

                    for await _ in app.on(blockchain.ux.transaction["sell"].event.did.finish) {
                        if app.currentMode == .trading {
                            app.post(event: blockchain.ux.buy.another.asset.entry)
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

public final class EarnWithCryptoObserver: Client.Observer {

    let app: AppProtocol

    public init(app: AppProtocol) {
        self.app = app
    }

    var task: Task<Void, Error>?

    public func start() {
        task = Task {
            try await app.set(blockchain.ux.earn.after.successful.swap.entry.then.enter.into, to: blockchain.ux.earn.after.successful.swap)
            try await withThrowingTaskGroup(of: Void.self) { [app] group in
                group.addTask {
                    for await status in app.stream(blockchain.ux.transaction.execution.status, as: Tag.self) {
                        guard let value = status.value else { continue }
                        try await app.set(blockchain.ux.earn.after.successful.swap.entry.policy.discard.if, to: value != blockchain.ux.transaction.event.execution.status.completed[])
                    }
                }
                group.addTask {
                    let valid = ["BTC","ETH","USDT","USDC","DAI","PAX"]
                    for await (date, currency, isPrivateKey) in
                            combineLatest(
                              app.stream(blockchain.ux.earn.after.successful.swap.maybe.later.timestamp, as: Date.self),
                              app.stream(blockchain.ux.transaction.source.target.id, as: CryptoCurrency.self),
                              app.stream(blockchain.ux.transaction.source.is.private.key, as: Bool.self)
                            ) {
//                        try await app.set(blockchain.ux.earn.after.successful.swap.entry.policy.perform.if, to: isPrivateKey.value == false &&  valid.contains(currency.value?.code ?? ""))
                        print("debug \(isPrivateKey.value) \(currency) \(date)")
                        try await app.set(blockchain.ux.earn.after.successful.swap.entry.policy.perform.if, to: isPrivateKey.value == false &&  valid.contains(currency.value?.code ?? "") && date.value.map { Calendar.current.numberOfDaysBetween($0, and: Date()) > 30 } ?? true)
                    }
                }
                group.addTask {
                    for await _ in app.on(blockchain.ux.transaction["swap"].event.did.finish) {
                        app.post(event: blockchain.ux.earn.after.successful.swap.entry)
                    }
                }
                try await group.waitForAll()
            }
        }
    }

    public func stop() { task?.cancel() }
}
