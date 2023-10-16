// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Errors
import SwiftUI

extension AccountPickerRow {

    public struct Capabilities: Hashable {
        let canWithdrawal: Bool?
        let canDeposit: Bool?

        public init(canWithdrawal: Bool?, canDeposit: Bool?) {
            self.canWithdrawal = canWithdrawal
            self.canDeposit = canDeposit
        }
    }

    public struct PaymentMethod: Equatable {

        // MARK: - Internal properties

        let id: AnyHashable
        let block: Bool
        let ux: UX.Dialog?
        var title: String
        var description: String
        var badge: ImageLocation?
        var badgeBackground: Color
        var capabilities: Capabilities?

        // MARK: - Init

        public init(
            id: AnyHashable,
            block: Bool = false,
            ux: UX.Dialog? = nil,
            title: String,
            description: String,
            badge: ImageLocation?,
            badgeBackground: Color,
            capabilities: Capabilities? = nil
        ) {
            self.id = id
            self.ux = ux
            self.block = block
            self.title = title
            self.description = description
            self.badge = badge
            self.badgeBackground = badgeBackground
            self.capabilities = capabilities
        }
    }
}
