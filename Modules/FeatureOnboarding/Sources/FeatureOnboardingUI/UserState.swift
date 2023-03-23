// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A data type representing the user state for Onboarding
public struct UserState: Equatable {

    public enum KYCStatus: Equatable {
        case notVerified
        case verificationPending
        case verified
    }

    public let kycStatus: KYCStatus
    public let hasLinkedPaymentMethods: Bool
    public let hasEverPurchasedCrypto: Bool

    public init(
        kycStatus: KYCStatus,
        hasLinkedPaymentMethods: Bool,
        hasEverPurchasedCrypto: Bool
    ) {
        self.kycStatus = kycStatus
        self.hasLinkedPaymentMethods = hasLinkedPaymentMethods
        self.hasEverPurchasedCrypto = hasEverPurchasedCrypto
    }
}

extension UserState.KYCStatus {

    var canBuyCrypto: Bool {
        switch self {
        case .notVerified, .verificationPending:
            return false
        case .verified:
            return true
        }
    }
}
