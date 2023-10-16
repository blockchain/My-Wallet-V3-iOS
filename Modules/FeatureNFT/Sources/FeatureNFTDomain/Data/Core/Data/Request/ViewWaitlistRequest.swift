// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct ViewWaitlistRequest: Encodable {
    let email: String
    let feature: String

    init(
        email: String,
        feature: String = "mobile_view_nft_support"
    ) {
        self.email = email
        self.feature = feature
    }
}
