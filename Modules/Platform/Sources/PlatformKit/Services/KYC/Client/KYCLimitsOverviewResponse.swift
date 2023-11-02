// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct KYCLimitsOverviewResponse: Equatable, Decodable {

    public struct Feature: Equatable, Decodable {

        public enum TimePeriod: String, Equatable, Decodable {
            case day = "DAY"
            case month = "MONTH"
            case year = "YEAR"
        }

        public struct PeriodicLimit: Equatable, Decodable {
            let value: MoneyValue?
            let period: TimePeriod
        }

        public let name: String
        public let enabled: Bool
        public let limit: PeriodicLimit?
    }

    public let limits: [Feature]
}

extension KYCLimitsOverview {

    init(tiers: KYC.UserTiers, features: [KYCLimitsOverviewResponse.Feature]) {
        let mappedFeatures = features
            .compactMap { rawFeature -> LimitedTradeFeature? in
                guard let identifier = LimitedTradeFeature.Identifier(rawValue: rawFeature.name) else {
                    return nil
                }
                return LimitedTradeFeature(
                    id: identifier,
                    enabled: rawFeature.enabled,
                    limit: rawFeature.limit?.mapToPeriodicLimit()
                )
            }
        self.init(
            tiers: tiers,
            features: mappedFeatures
        )
    }
}

extension KYCLimitsOverviewResponse.Feature.TimePeriod {

    func mapToTimePeriod() -> LimitedTradeFeature.TimePeriod {
        switch self {
        case .day:
            .day
        case .month:
            .month
        case .year:
            .year
        }
    }
}

extension KYCLimitsOverviewResponse.Feature.PeriodicLimit {

    func mapToPeriodicLimit() -> LimitedTradeFeature.PeriodicLimit {
        LimitedTradeFeature.PeriodicLimit(
            value: value,
            period: period.mapToTimePeriod()
        )
    }
}
