// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import FeatureAuthenticationDomain

extension AnalyticsEvents.New {
    enum AccountRecoveryCoreFlow: AnalyticsEvent, Equatable {
        case accountPasswordReset(
            hasRecoveryPhrase: Bool
        )
        case accountRecoveryFailed

        var type: AnalyticsEventType { .nabu }

        var params: [String: Any]? {
            switch self {
            case .accountPasswordReset(let hasRecoveryPhrase):
                [
                    "has_recovery_phrase": hasRecoveryPhrase
                ]
            case .accountRecoveryFailed:
                [:]
            }
        }
    }
}
