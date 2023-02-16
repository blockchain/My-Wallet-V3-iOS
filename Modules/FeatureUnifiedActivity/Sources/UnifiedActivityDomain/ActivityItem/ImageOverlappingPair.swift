// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityItem {
    public struct ImageOverlappingPair: Equatable, Codable, Hashable {
        public let back: String?
        public let front: String?

        public init(
            back: String?,
            front: String?
        ) {
            self.back = back
            self.front = front
        }
    }
}
