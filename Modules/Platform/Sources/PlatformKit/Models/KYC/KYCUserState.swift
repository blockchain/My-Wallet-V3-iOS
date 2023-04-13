// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension KYC {
    public struct UserState: Decodable, Equatable {
        public let current: KYC.Tier
        public let selected: KYC.Tier
        public let next: KYC.Tier

        enum CodingKeys: String, CodingKey {
            case current
            case selected
            case next
        }

        public init(current: KYC.Tier, selected: KYC.Tier, next: KYC.Tier) {
            self.current = current
            self.selected = selected
            self.next = next
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.current = try values.decodeIfPresent(KYC.Tier.self, forKey: .current) ?? .unverified
            self.selected = try values.decodeIfPresent(KYC.Tier.self, forKey: .current) ?? .unverified
            self.next = try values.decodeIfPresent(KYC.Tier.self, forKey: .current) ?? .unverified
        }
    }
}
