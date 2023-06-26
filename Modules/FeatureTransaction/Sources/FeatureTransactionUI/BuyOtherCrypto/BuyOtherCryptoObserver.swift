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

