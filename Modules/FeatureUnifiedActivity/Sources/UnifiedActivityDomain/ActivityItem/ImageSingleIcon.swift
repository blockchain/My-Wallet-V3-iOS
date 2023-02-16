// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityItem {
    public struct ImageSingleIcon: Equatable, Codable, Hashable {
        public let url: String?

        public init(url: String?) {
            self.url = url
        }
    }
}
