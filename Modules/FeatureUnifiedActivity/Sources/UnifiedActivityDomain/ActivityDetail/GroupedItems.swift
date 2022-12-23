// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityDetail {
    public struct GroupedItems: Equatable, Codable {
        public struct Item: Equatable, Codable, Identifiable {
            enum CodingKeys: CodingKey {
                case title
                case itemGroup
            }

            public init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<ActivityDetail.GroupedItems.Item.CodingKeys> = try decoder.container(keyedBy: ActivityDetail.GroupedItems.Item.CodingKeys.self)
                self.title = try container.decodeIfPresent(String.self, forKey: ActivityDetail.GroupedItems.Item.CodingKeys.title)
                self.itemGroup = try container.decode([ItemType].self, forKey: ActivityDetail.GroupedItems.Item.CodingKeys.itemGroup)
                self.id = UUID().uuidString
            }

            public init(
                title: String,
                itemGroup: [ItemType]
            ) {
                self.id = UUID().uuidString
                self.title = title
                self.itemGroup = itemGroup
            }

            public var id: String
            public let title: String?
            public let itemGroup: [ItemType]
        }

        public init(
            title: String,
            icon: ImageType,
            itemGroups: [ActivityDetail.GroupedItems.Item],
            floatingActions: [ActivityItem.Button]
        ) {
            self.title = title
            self.icon = icon
            self.itemGroups = itemGroups
            self.floatingActions = floatingActions
        }

        public let title: String?
        // public let subtitle: String? // Legacy
        public let icon: ImageType
        public let itemGroups: [Item]
        public let floatingActions: [ActivityItem.Button]
    }
}
