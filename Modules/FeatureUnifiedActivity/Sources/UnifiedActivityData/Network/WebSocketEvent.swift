// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit
import UnifiedActivityDomain

enum Channel: String, Codable {
    case activity
    case heartbeat
}

enum EventType: String, Codable {
    case snapshot
    case update
}

enum WebSocketEvent: Decodable, Equatable {
    case heartbeat
    case snapshot(Payload)
    case update(Payload)

    private enum CodingKeys: String, CodingKey {
        case channel
        case event
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let channel = try container.decode(Channel.self, forKey: .channel)
        let event = try container.decode(EventType.self, forKey: .event)

        switch channel {
        case .heartbeat:
            self = .heartbeat
        case .activity:
            switch event {
            case .update:
                self = try .update(Payload(from: decoder))
            case .snapshot:
                self = try .snapshot(Payload(from: decoder))
            }
        }
    }
}

extension WebSocketEvent {
    struct Payload: Equatable, Decodable {
        let event: EventType
        let channel: Channel
        let data: Content
    }
}

extension WebSocketEvent.Payload {
    struct Content: Equatable, Decodable {
        struct Item: Equatable, Decodable {
            let id: String
            let externalUrl: String
            let item: ActivityItem.CompositionView
            let state: ActivityState
            let timestamp: TimeInterval
        }

        let network: String
        let pubKey: String
        let activity: [Item]
    }
}

extension ActivityEntry {
    init(network: String, pubKey: String, item: WebSocketEvent.Payload.Content.Item) {
        self.init(
            id: item.id,
            network: network,
            pubKey: pubKey,
            externalUrl: item.externalUrl,
            item: item.item,
            state: item.state,
            timestamp: item.timestamp
        )
    }
}
