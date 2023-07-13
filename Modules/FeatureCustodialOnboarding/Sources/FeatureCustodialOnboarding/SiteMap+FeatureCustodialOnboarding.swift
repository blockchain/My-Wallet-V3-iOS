import BlockchainUI
import SwiftUI

public struct SiteMap {

    @StateObject var service = CustodialOnboardingService()

    public init() {}

    @ViewBuilder public func view(for tag: Tag.Reference, in context: Tag.Context) throws -> some View {
        switch tag {
        case blockchain.ux.user.custodial.onboarding.dashboard:
            CustodialOnboardingDashboardView(service: service)
        case blockchain.ux.user.custodial.onboarding.before.you.continue:
            BeforeYouContinuePleaseVerifyView()
        case blockchain.ux.user.custodial.onboarding.verification.is.in.progress:
            VerificationInProgressView()
        default:
            throw "Unhandled \(tag)".error()
        }
    }
}
