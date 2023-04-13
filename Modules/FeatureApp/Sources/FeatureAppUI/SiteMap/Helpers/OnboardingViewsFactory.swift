//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainUI
import DIKit
import FeatureAppDomain
import FeatureDashboardUI
import FeatureOnboardingUI
import FeatureTransactionUI
import PlatformKit
import PlatformUIKit
import SwiftUI

final class OnboardingViewsFactory {

    private let app: AppProtocol
    private let kycAdapter: KYCAdapter
    private let userAdapter: UserAdapterAPI
    private let transactionsAdapter: TransactionsAdapterAPI
    private let paymentMethodLinkingAdapter: PaymentMethodsLinkingAdapterAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        app: AppProtocol = resolve(),
        kycAdapter: KYCAdapter = KYCAdapter(),
        userAdapter: UserAdapterAPI = resolve(),
        transactionsAdapter: TransactionsAdapterAPI = resolve(),
        paymentMethodLinkingAdapter: PaymentMethodsLinkingAdapterAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.app = app
        self.kycAdapter = kycAdapter
        self.userAdapter = userAdapter
        self.transactionsAdapter = transactionsAdapter
        self.paymentMethodLinkingAdapter = paymentMethodLinkingAdapter
        self.analyticsRecorder = analyticsRecorder
    }

    func makeOnboardingChecklistOverview() -> some View {
        OnboardingChecklistOverview(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: makeOnboardingChecklistEnvironment()
            )
        )
    }

    func makeOnboardingChecklistView() -> some View {
        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: makeOnboardingChecklistEnvironment()
            )
        )
    }

    private func makeOnboardingChecklistEnvironment() -> OnboardingChecklist.Environment {
        OnboardingChecklist.Environment(
            app: app,
            userState: userAdapter.onboardingUserState,
            presentBuyFlow: { [transactionsAdapter] completion in
                if let viewController = UIApplication.shared.topMostViewController {
                    transactionsAdapter.presentTransactionFlow(
                        to: .buy(nil),
                        from: viewController
                    ) { result in
                        // view is dismissed automatically, so, no need to do that
                        completion(result == .completed)
                    }
                }
            },
            presentKYCFlow: { [kycAdapter] completion in
                if let viewController = UIApplication.shared.topMostViewController {
                    kycAdapter.presentKYCIfNeeded(
                        from: viewController,
                        requireEmailVerification: true,
                        requiredTier: .verified
                    ) { result in
                        // view is dismissed automatically, so, no need to do that
                        completion(result == .completed || result == .skipped)
                    }
                }
            },
            presentPaymentMethodLinkingFlow: { [paymentMethodLinkingAdapter] completion in
                if let viewController = UIApplication.shared.topMostViewController {
                    paymentMethodLinkingAdapter.routeToPaymentMethodLinkingFlow(
                        from: viewController,
                        completion: { result in
                            switch result {
                            case .completed(let method)
                                where method?.type.isApplePay == true:
                                completion(true)
                            case .completed, .abandoned:
                                viewController.dismiss(animated: true) {
                                    // If completion true, launches the buy flow
                                    completion(false)
                                }
                            }
                        }
                    )
                }
            },
            analyticsRecorder: analyticsRecorder
        )
    }
}
