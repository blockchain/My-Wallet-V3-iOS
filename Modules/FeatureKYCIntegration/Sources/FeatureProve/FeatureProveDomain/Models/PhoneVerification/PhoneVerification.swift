// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions

public struct PhoneVerification: Equatable {
    public let isVerified: Bool
    public let phone: String?

    public init(isVerified: Bool, phone: String? = nil) {
        self.isVerified = isVerified
        self.phone = phone
    }
}
