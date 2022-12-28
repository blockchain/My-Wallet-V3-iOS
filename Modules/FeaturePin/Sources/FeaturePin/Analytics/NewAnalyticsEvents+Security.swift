// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import FeatureAuthenticationDomain

extension AnalyticsEvents.New {
    enum Security: AnalyticsEvent {
        var type: AnalyticsEventType { .nabu }

        case mobilePinCodeChanged
        case verificationCodeSubmitted(twoStepOption: Option)

        enum Option: String, StringRawRepresentable {
            case mobileNumber = "MOBILE_NUMBER"
        }
    }
}
