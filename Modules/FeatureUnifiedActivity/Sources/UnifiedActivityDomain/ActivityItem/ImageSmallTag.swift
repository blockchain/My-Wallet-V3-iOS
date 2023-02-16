// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityItem {
    public struct ImageSmallTag: Equatable, Codable, Hashable {
        public let main: String?
        public let tag: String?

        public var hasTagImage: Bool {
            tag != nil
        }

        public init(main: String?, tag: String? = nil) {
            self.main = main
            self.tag = tag
        }
    }
}
