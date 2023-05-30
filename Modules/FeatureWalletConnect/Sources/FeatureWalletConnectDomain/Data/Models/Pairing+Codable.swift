// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Web3Wallet

extension Pairing: Codable {
    enum Key: CodingKey {
        case topic
        case peer
        case expiryDate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let topic = try container.decode(String.self, forKey: .topic)
        let peer = try container.decodeIfPresent(AppMetadata.self, forKey: .peer)
        let expireDate = try container.decode(Date.self, forKey: .expiryDate)
        self = .init(topic: topic, peer: peer, expiryDate: expireDate)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(topic, forKey: .topic)
        try container.encodeIfPresent(peer, forKey: .peer)
        try container.encode(expiryDate, forKey: .expiryDate)
    }
}

extension Pairing: Hashable {
    public static func == (lhs: Pairing, rhs: Pairing) -> Bool {
        lhs.topic == rhs.topic
        && lhs.peer == rhs.peer
        && lhs.expiryDate == rhs.expiryDate
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.topic)
        hasher.combine(self.peer)
        hasher.combine(self.expiryDate)
    }
}
