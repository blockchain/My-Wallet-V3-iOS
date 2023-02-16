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

extension ActivityDetail {
    public static let placeholderIcon = ImageType.smallTag(ActivityItem.ImageSmallTag.init(main: nil))
    public static let placeholderItems = GroupedItems(
        title: "Placeholder Title",
        icon: placeholderIcon,
        itemGroups: [
            .init(
                title: "a",
                itemGroup: providePlaceholderItems(total: 4)
            ),
            .init(
                title: "b",
                itemGroup: providePlaceholderItems(total: 2)
            ),
            .init(
                title: "c",
                itemGroup: providePlaceholderItems(total: 3)
            )
        ],
        floatingActions: []
    )

    static func providePlaceholderItems(total: Int = 3) -> [ItemType] {
        (0..<total).map { i in
            .compositionView(
                .init(
                    leading: [
                        .text(.init(value: "Placeholder Text \(i)", style: .init(typography: .body1, color: .title)))
                    ],
                    trailing: [
                        .text(.init(value: "£Amount\(i)", style: .init(typography: .body1, color: .title)))
                    ]
                )
            )
        }
    }
}
