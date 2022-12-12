// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityItem {
    public struct CompositionView: Equatable, Codable, Hashable {
        public let leadingImage: ImageType?
        public let leading: [LeafItemType]
        public let trailing: [LeafItemType]
        public let trailingImage: ImageType?
    }
}
