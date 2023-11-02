// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.SearchDomain

public enum DomainType: Equatable, Hashable {
    case free
    case premium

    public var statusLabel: String {
        switch self {
        case .free:
            LocalizedString.ListView.freeDomain
        case .premium:
            LocalizedString.ListView.premiumDomain
        }
    }
}

public enum DomainAvailability: Equatable, Hashable {
    case availableForFree
    case availableForPremiumSale(price: String)
    case unavailable

    public var availabilityLabel: String {
        switch self {
        case .availableForFree:
            LocalizedString.ListView.free
        case .availableForPremiumSale(let price):
            "$\(price)"
        case .unavailable:
            LocalizedString.ListView.unavailable
        }
    }
}

public struct SearchDomainResult: Equatable, Hashable {
    public let domainName: String
    public let domainType: DomainType
    public let domainAvailability: DomainAvailability

    public init(
        domainName: String,
        domainType: DomainType,
        domainAvailability: DomainAvailability
    ) {
        self.domainName = domainName
        self.domainType = domainType
        self.domainAvailability = domainAvailability
    }
}
