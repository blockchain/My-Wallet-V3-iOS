// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
            return .none
        case .rejected:
            return .failed
        case .pending:
            return .pending
        case .verified:
            return .approved
        case .under_review:
            return .underReview
        }
    }
}
