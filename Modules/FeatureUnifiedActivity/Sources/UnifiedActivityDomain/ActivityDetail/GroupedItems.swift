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
                let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
                self.title = try container.decodeIfPresent(String.self, forKey: CodingKeys.title)
                self.itemGroup = try container.decode([ItemType].self, forKey: CodingKeys.itemGroup)
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
        public let icon: ImageType
        public let itemGroups: [Item]
        public let floatingActions: [ActivityItem.Button]
    }
}

extension ActivityDetail {
    public static let placeholderIcon = ImageType.smallTag(ActivityItem.ImageSmallTag(main: nil))
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
        let style = ActivityItem.Text.Style(typography: .body1, color: .title)
        return (0..<total)
            .map { idx in
                    .compositionView(
                        .init(
                            leading: [.text(.init(value: "Placeholder Text \(idx)", style: style))],
                            trailing: [.text(.init(value: "£Amount\(idx)", style: style))]
                        )
                    )
            }
    }
}
