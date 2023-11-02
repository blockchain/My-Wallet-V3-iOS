// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import FeatureAuthenticationDomain

// TODO: refactor this when secure channel is moved to feature authentication
enum LoginSource {
    case secureChannel
    case magicLink
}

extension AnalyticsEvents.New {
    enum LoginFlow: AnalyticsEvent, Equatable {
        case loginClicked(
            origin: Origin
        )
        case loginViewed
        case loginIdentifierEntered(
            identifierType: IdentifierType
        )
        case loginIdentifierFailed(
            errorMessage: String
        )
        case loginPasswordEntered
        case loginRequestApproved(LoginSource)
        case loginRequestDenied(LoginSource)
        case loginTwoStepVerificationEntered
        case loginTwoStepVerificationDenied

        var type: AnalyticsEventType { .nabu }

        var params: [String: Any]? {
            switch self {
            case .loginPasswordEntered,
                 .loginTwoStepVerificationEntered,
                 .loginViewed,
                 .loginTwoStepVerificationDenied:
                [:]

            case .loginRequestApproved(let source),
                 .loginRequestDenied(let source):
                [
                    "login_source": String(describing: source)
                ]

            case .loginClicked(let origin):
                [
                    "origin": origin.rawValue
                ]

            case .loginIdentifierEntered(let identifierType):
                [
                    "identifier_type": identifierType.rawValue
                ]

            case .loginIdentifierFailed(let errorMessage):
                [
                    "error_message": errorMessage,
                    "device": Device.iOS.rawValue,
                    "platform": Platform.wallet.rawValue
                ]
            }
        }

        // MARK: Helpers

        enum IdentifierType: String, StringRawRepresentable {
            case email = "EMAIL"
            case walletId = "WALLET-ID"
        }

        enum Device: String, StringRawRepresentable {
            case iOS = "APP-iOS"
        }

        enum Origin: String, StringRawRepresentable {
            case navigation = "NAVIGATION"
        }
    }
}

extension AnalyticsEvents.New.LoginFlow {
    /// - Returns: The case of `.loginClicked` with default parameters
    static func loginClicked() -> Self {
        .loginClicked(
            origin: .navigation
        )
    }
}

extension AnalyticsEventRecorderAPI {
    /// Helper method to record `LoginFlow` events
    /// - Parameter event: A `LoginFlow` event to be tracked
    func record(event: AnalyticsEvents.New.LoginFlow) {
        record(event: event)
    }
}
