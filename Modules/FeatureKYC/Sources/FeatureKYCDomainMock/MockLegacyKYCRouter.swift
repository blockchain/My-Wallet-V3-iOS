// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift

final class MockLegacyKYCRouter: PlatformUIKit.KYCRouterAPI {

    struct RecordedInvocations {
        var start: [(tier: KYC.Tier, parentFlow: KYCParentFlow, from: UIViewController?)] = []
    }

    struct StubbedResults {
        var kycStopped: Observable<Void> = .empty()
        var kycFinished: Observable<KYC.Tier> = .empty()
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    var verifiedFinished: Observable<Void> {
        kycFinished.mapToVoid()
    }

    var kycStopped: Observable<Void> {
        stubbedResults.kycStopped
    }

    var kycFinished: Observable<KYC.Tier> {
        stubbedResults.kycFinished
    }

    func start(parentFlow: KYCParentFlow) {
        start(tier: .verified, parentFlow: parentFlow)
    }

    func start(tier: KYC.Tier, parentFlow: KYCParentFlow) {
        start(tier: tier, parentFlow: parentFlow, from: nil)
    }

    func start(tier: KYC.Tier, parentFlow: KYCParentFlow, from viewController: UIViewController?) {
        recordedInvocations.start.append((tier, parentFlow, viewController))
    }
}
