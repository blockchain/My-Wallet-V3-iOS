// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import PlatformKit
import RxSwift

public final class MockKYCTiersService: PlatformKit.KYCTiersServiceAPI {

    public struct RecordedInvocations {
        public var fetchTiers: [Void] = []
        public var fetchOverview: [Void] = []
    }

    public struct StubbedResponses {
        public var fetchTiers: AnyPublisher<KYC.UserTiers, Nabu.Error> = .empty()
        public var fetchOverview: AnyPublisher<KYCLimitsOverview, Nabu.Error> = .empty()
    }

    public private(set) var recordedInvocations = RecordedInvocations()
    public var stubbedResponses = StubbedResponses()

    public var tiers: AnyPublisher<KYC.UserTiers, Nabu.Error> {
        fetchTiers()
    }

    public var tiersStream: AnyPublisher<KYC.UserTiers, Nabu.Error> {
        fetchTiers()
    }

    public func fetchTiers() -> AnyPublisher<KYC.UserTiers, Nabu.Error> {
        recordedInvocations.fetchTiers.append(())
        return stubbedResponses.fetchTiers
    }

    public func fetchOverview() -> AnyPublisher<KYCLimitsOverview, Nabu.Error> {
        recordedInvocations.fetchOverview.append(())
        return stubbedResponses.fetchOverview
    }
}
