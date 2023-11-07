// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import FeatureAuthenticationDomain

extension AnalyticsEvents.New {
    enum AccountRecoveryFlow: AnalyticsEvent, Equatable {
        case importWalletCancelled
        case importWalletClicked
        case importWalletConfirmed
        case recoveryOptionSelected
        case recoveryPhraseEntered
        case resetAccountCancelled
        case resetAccountClicked

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
            default:
                [:]
            }
        }
    }
}

extension AnalyticsEventRecorderAPI {
    /// Helper method to record `AccountRecoveryFlow` events
    /// - Parameter event: A `AccountRecoveryFlow` event to be tracked
    func record(event: AnalyticsEvents.New.AccountRecoveryFlow) {
        record(event: event)
    }
}
