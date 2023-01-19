// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityItem {
    public struct CompositionView: Equatable, Codable, Hashable {
        public let leadingImage: ImageType?
        public let leading: [LeafItemType]
        public let trailing: [LeafItemType]
        public let trailingImage: ImageType?

        public init(
            leadingImage: ImageType? = nil,
            leading: [LeafItemType],
            trailing: [LeafItemType],
            trailingImage: ImageType? = nil
        ) {
            self.leadingImage = leadingImage
            self.leading = leading
            self.trailing = trailing
            self.trailingImage = trailingImage
        }
    }
}
