// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureKYCUI
import Localization
import PlatformKit
import XCTest

class KYCUserTierTests: XCTestCase {
    func testLockedState() {
        let userVerified = KYC.UserTier(tier: .verified, state: .none)
        let response = KYC.UserTiers(tiers: [userVerified])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        XCTAssertNil(badgeModel)
    }

    func testVerifiedVerified() {
        let userVerified = KYC.UserTier(tier: .verified, state: .verified)
        let response = KYC.UserTiers(tiers: [userVerified])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.verified + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func testVerifiedState() {
        let userVerified = KYC.UserTier(tier: .verified, state: .verified)
        let response = KYC.UserTiers(tiers: [userVerified])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.verified + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func verifiedPending() {
        let userVerified = KYC.UserTier(tier: .verified, state: .pending)
        let response = KYC.UserTiers(tiers: [userVerified])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.verified + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
}

extension KYC.UserTier {
    fileprivate static let verifiedRejected = KYC.UserTier(tier: .verified, state: .rejected)
    fileprivate static let verifiedApproved = KYC.UserTier(tier: .verified, state: .verified)
    fileprivate static let verifiedPending = KYC.UserTier(tier: .verified, state: .pending)
    fileprivate static let verifiedNone = KYC.UserTier(tier: .verified, state: .none)
}
