// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension AccountPickerRow {

    public struct LinkedBankAccount: Equatable {

        // MARK: - Internal properties

        var capabilities: Capabilities?
        var title: String
        var description: String
        var badgeImage: Image?
        var multiBadgeView: Image?

        let id: AnyHashable

        // MARK: - Init

        public init(
            id: AnyHashable,
            title: String,
            description: String,
            badgeImage: Image? = nil,
            multiBadgeView: Image? = nil,
            capabilities: Capabilities? = nil
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.badgeImage = badgeImage
            self.multiBadgeView = multiBadgeView
            self.capabilities = capabilities
        }
    }
}
