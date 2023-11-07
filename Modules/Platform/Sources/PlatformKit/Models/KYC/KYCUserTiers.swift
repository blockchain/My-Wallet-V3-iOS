// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Errors
import Foundation

extension KYC {
    public struct UserTiers: Decodable, Equatable {
        public let tiers: [KYC.UserTier]

        public var isUnverified: Bool {
            latestApprovedTier == .unverified
        }

        /// `true` if tier 2 is in manual review or pending
        public var isVerifiedPending: Bool {
            tierAccountStatus(for: .verified) == .underReview || tierAccountStatus(for: .verified) == .pending
        }

        /// `true` in case the user has a verified GOLD tier.
        public var isVerifiedApproved: Bool {
            tierAccountStatus(for: .verified) == .approved
        }

        public init(tiers: [KYC.UserTier]) {
            self.tiers = tiers
        }

        /// Returns the KYC.AccountStatus for the given KYC.Tier
        public func tierAccountStatus(for tier: KYC.Tier) -> KYC.AccountStatus {
            tiers
                .first(where: { $0.tier == tier })
                .map(\.state.accountStatus) ?? .none
        }

        /// Returns the latest tier, approved OR in progress (pending || in-review)
        public var latestTier: KYC.Tier {
            guard tierAccountStatus(for: .verified).isInProgressOrApproved else {
                return .unverified
            }
            return .verified
        }

        /// Returns the latest approved tier
        public var latestApprovedTier: KYC.Tier {
            guard tierAccountStatus(for: .verified).isApproved else {
                return .unverified
            }
            return .verified
        }

        /// Returns `true` if the user is not verified verified, rejected or pending
        public var canCompleteVerified: Bool {
            tiers.contains(where: {
                $0.tier == .verified &&
                    ($0.state != .pending && $0.state != .rejected && $0.state != .verified)
            })
        }
    }

    public struct SSN: Codable, Hashable {

        public struct Requirements: Codable, Hashable {
            public let isMandatory: Bool
            public let validationRegex: String
        }

        public struct Verification: Codable, Hashable {

            public struct State: NewTypeString {
                public var value: String
                public init(_ value: String) { self.value = value }
            }

            public let state: State
            public let errorMessage: String?
        }

        public let requirements: Requirements
        public let verification: Verification?
    }
}

extension KYC.SSN.Verification.State {

    public static let required = Self("REQUIRED")
    public static let pending = Self("PENDING")
    public static let rejected = Self("REJECTED")
    public static let verified = Self("VERIFIED")

    public var isFinal: Bool { self != .pending }
}

extension KYC.UserTiers {

    public func canPurchaseCrypto() -> Bool {
        isVerifiedApproved
    }
}

extension KYC.Tier.State {
    fileprivate var accountStatus: KYC.AccountStatus {
        switch self {
        case .none:
            .none
        case .rejected:
            .failed
        case .pending:
            .pending
        case .verified:
            .approved
        case .under_review:
            .underReview
        }
    }
}
