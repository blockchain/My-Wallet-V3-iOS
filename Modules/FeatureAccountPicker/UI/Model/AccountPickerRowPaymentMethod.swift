// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import PlatformKit
import SwiftUI

extension AccountPickerRow {

    public struct PaymentMethod: Equatable {

        // MARK: - Internal properties

        let id: AnyHashable
        let block: Bool
        let ux: UX.Dialog?
        var title: String
        var description: String
        var badgeView: Image?
        var badgeURL: URL?
        var badgeBackground: Color
        var capabilities: Capabilities?

        // MARK: - Init

        public init(
            id: AnyHashable,
            block: Bool = false,
            ux: UX.Dialog? = nil,
            title: String,
            description: String,
            badgeView: Image?,
            badgeURL: URL? = nil,
            badgeBackground: Color,
            capabilities: Capabilities? = nil
        ) {
            self.id = id
            self.ux = ux
            self.block = block
            self.title = title
            self.description = description
            self.badgeView = badgeView
            self.badgeURL = badgeURL
            self.badgeBackground = badgeBackground
            self.capabilities = capabilities
        }
    }
}
