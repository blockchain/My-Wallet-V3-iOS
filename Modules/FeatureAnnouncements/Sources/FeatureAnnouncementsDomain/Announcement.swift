// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Foundation

public struct Announcement: Decodable, Identifiable, Equatable, Comparable {

    public static func < (lhs: Announcement, rhs: Announcement) -> Bool {
        if lhs.priority == rhs.priority {
            lhs.createdAt > rhs.createdAt
        } else {
            lhs.priority < rhs.priority
        }
    }

    public enum Action: String, Codable, Equatable {
        case swipe = "swiped"
        case open = "clicked"
    }

    public enum AppMode: String, Decodable, Equatable {
        case defi
        case trading
        case universal
    }

    enum CodingKeys: String, CodingKey {
        case id = "messageId"
        case createdAt
        case content = "customPayload"
        case priority = "priorityLevel"
        case read
        case expiresAt
    }

    public struct Content: Decodable, Equatable {
        public let title: String
        public let description: String
        public let imageUrl: URL?
        public let icon: Icon?
        public let actionUrl: String
        public let appMode: AppMode

        public init(
            title: String,
            description: String,
            imageUrl: URL? = nil,
            icon: Icon? = nil,
            actionUrl: String,
            appMode: Announcement.AppMode
        ) {
            self.title = title
            self.description = description
            self.icon = icon
            self.imageUrl = imageUrl
            self.actionUrl = actionUrl
            self.appMode = appMode
        }
    }

    public let id: String
    public let createdAt: Date
    public let content: Content
    public let priority: Double
    public let read: Bool
    public let expiresAt: Date

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Announcement.CodingKeys> = try decoder.container(keyedBy: Announcement.CodingKeys.self)

        self.id = try container.decode(String.self, forKey: Announcement.CodingKeys.id)
        self.content = try container.decode(Content.self, forKey: Announcement.CodingKeys.content)
        self.priority = try container.decode(Double.self, forKey: Announcement.CodingKeys.priority)
        self.read = try container.decode(Bool.self, forKey: Announcement.CodingKeys.read)

        let createdAt = try container.decode(Double.self, forKey: Announcement.CodingKeys.createdAt)
        self.createdAt = Date(timeIntervalSince1970: createdAt / 1000)

        let expiresAt = try container.decode(Double.self, forKey: Announcement.CodingKeys.createdAt)
        self.expiresAt = Date(timeIntervalSince1970: expiresAt / 1000)
    }

    public init(
        id: String,
        createdAt: Date,
        content: Announcement.Content,
        priority: Double,
        read: Bool,
        expiresAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.content = content
        self.priority = priority
        self.read = read
        self.expiresAt = expiresAt
    }
}
