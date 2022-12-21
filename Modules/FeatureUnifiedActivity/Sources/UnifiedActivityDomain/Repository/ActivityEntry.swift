// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum ActivityState: String, Equatable, Codable, Hashable {
    case failed = "FAILED"
    case pending = "PENDING"
    case completed = "COMPLETED"
    case confirming = "CONFIRMING"
    case unknown
}

public struct ActivityEntry: Equatable, Codable, Hashable {
    public let id: String
    public let network: String
    public let pubKey: String
    public let externalUrl: String
    public let item: ActivityItem.CompositionView
    public let state: ActivityState
    public let timestamp: TimeInterval

    public init(
        id: String,
        network: String,
        pubKey: String,
        externalUrl: String,
        item: ActivityItem.CompositionView,
        state: ActivityState,
        timestamp: TimeInterval
    ) {
        self.id = id
        self.network = network
        self.pubKey = pubKey
        self.externalUrl = externalUrl
        self.item = item
        self.state = state
        self.timestamp = timestamp
    }
}


extension ActivityEntry {
    public var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
}
