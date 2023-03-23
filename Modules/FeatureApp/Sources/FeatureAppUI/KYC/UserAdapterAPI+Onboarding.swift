//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAppDomain
import FeatureOnboardingUI

extension UserAdapterAPI {

    /// A publisher that streams `FeatureOnboardingUI.UserState` values on subscription and on change by mapping values streamed by `userState`
    public var onboardingUserState: AnyPublisher<FeatureOnboardingUI.UserState, Never> {
        userState
            .compactMap { result -> FeatureAppDomain.UserState? in
                guard case .success(let userState) = result else {
                    return nil
                }
                return userState
            }
            .map { userState -> FeatureOnboardingUI.UserState in
                FeatureOnboardingUI.UserState(
                    kycStatus: .init(userState.kycStatus),
                    hasLinkedPaymentMethods: !userState.linkedPaymentMethods.isEmpty,
                    hasEverPurchasedCrypto: userState.hasEverPurchasedCrypto
                )
            }
            .eraseToAnyPublisher()
    }
}

extension FeatureOnboardingUI.UserState.KYCStatus {

    init(_ kycStatus: FeatureAppDomain.UserState.KYCStatus) {
        switch kycStatus {
        case .unverified:
            self = .notVerified
        case .gold:
            self = .verified
        case .inReview:
            self = .verificationPending
        }
    }
}
