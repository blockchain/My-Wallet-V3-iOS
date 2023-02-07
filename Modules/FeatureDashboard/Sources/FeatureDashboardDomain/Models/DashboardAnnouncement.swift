// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Foundation

public struct DashboardAnnouncement {
    public var id: String
    public var title: String
    public var message: String
    public var action: Tag.Event

    public init(id: String, title: String, message: String, action: Tag.Event) {
        self.id = id
        self.title = title
        self.message = message
        self.action = action
    }
}

extension DashboardAnnouncement: Equatable {
    public static func == (lhs: DashboardAnnouncement, rhs: DashboardAnnouncement) -> Bool {
        lhs.id == rhs.id
    }
}
