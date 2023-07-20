// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct NabuSessionToken {

    public let identifier: String
    public let userId: String
    public let token: String
    public let isActive: Bool
    public let expiresAt: Date?

    public init(
        identifier: String,
        userId: String,
        token: String,
        isActive: Bool,
        expiresAt: Date?
    ) {
        self.identifier = identifier
        self.userId = userId
        self.token = token
        self.isActive = isActive
        self.expiresAt = expiresAt
    }

    /// A boolean indicating if this token is still valid.
    public var isValid: Bool {
        guard let expiresAt else {
            // If we don't have 'expiresAt', assume it is valid.
            return true
        }
        let now = Date()
        // This session token will be assumed invalid 60 seconds from expiring.
        let invalidDate = expiresAt.addingTimeInterval(-60)
        return invalidDate >= now
    }
}
