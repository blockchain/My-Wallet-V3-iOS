// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Foundation

public struct AssetFilter: OptionSet, Hashable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let custodial = AssetFilter(rawValue: 1 << 0)
    public static let nonCustodial = AssetFilter(rawValue: 1 << 1)
    public static let interest = AssetFilter(rawValue: 1 << 2)
    public static let exchange = AssetFilter(rawValue: 1 << 3)
    public static let staking = AssetFilter(rawValue: 1 << 4)
    public static let activeRewards = AssetFilter(rawValue: 1 << 4)

    public static let all: AssetFilter = [.custodial, .nonCustodial, .interest, .exchange, .staking, .activeRewards]
    public static let allExcludingExchange: AssetFilter = [.custodial, .nonCustodial, .interest, .staking, .activeRewards]
    public static let allCustodial: AssetFilter = [.custodial, .interest, .staking, .activeRewards]
    public static let `default`: AssetFilter = [.allExcludingExchange]
}

extension AppMode {
    public var filter: AssetFilter {
        switch self {
        case .universal:
            return .allExcludingExchange
        case .pkw:
            return .nonCustodial
        case .trading:
            return [.custodial, .interest, .staking]
        }
    }
}
