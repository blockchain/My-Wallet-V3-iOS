// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension KYC {
    /// Enumerates the different tiers for KYC. A higher tier requires
    /// users to provide us with more information about them which
    /// qualifies them for higher limits of trading.
    ///
    /// - verified: the 2nd tier requiring the user to provide additional
    ///          identity information such as a drivers licence, passport,
    ///          etc.
    /// - SeeAlso: https://docs.google.com/spreadsheets/d/1BEdFJtbXpjcwolOljFRVBDjoe6GAoGvUkFCOzlUM_dM/edit#gid=1035097792
    public enum Tier: Int, CaseIterable, Codable, Comparable {

        case unverified = 0
        case verified = 2

        public init(from decoder: Decoder) throws {
            switch try Int(from: decoder) {
            case 2: self = .verified
            default: self = .unverified
            }
        }

        // It's best to use comparison to compare tiers instead of using `==` directly
        // since additional values are likely to be added in future
        public static func < (lhs: Tier, rhs: Tier) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

extension KYC.Tier {

    public var isUnverified: Bool {
        self == .unverified
    }

    public var isVerified: Bool {
        self == .verified
    }
}
