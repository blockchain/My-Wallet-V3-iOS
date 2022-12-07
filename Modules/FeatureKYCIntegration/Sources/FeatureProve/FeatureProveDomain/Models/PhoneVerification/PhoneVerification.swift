// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions

public struct PhoneVerification: Equatable {
    public struct Status: NewTypeString {

        public private(set) var value: String

        public init(_ value: String) { self.value = value }

        public static let verified: Self = "VERIFIED"
        public static let unverified: Self = "UNVERIFIED"
    }
    public let status: Status

    public init(status: Status) {
        self.status = status
    }
}
