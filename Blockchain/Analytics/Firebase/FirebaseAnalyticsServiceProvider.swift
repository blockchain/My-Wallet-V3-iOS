// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import DIKit
import FirebaseAnalytics
import Foundation
import PlatformKit
import ToolKit

class FirebaseAnalyticsServiceProvider: AnalyticsServiceProviderAPI {
    var supportedEventTypes: [AnalyticsEventType] = [.firebase]

    private enum FirebaseConstants {

        enum MaxLength {

            static let key = 40
            static let value = 100
        }

        static let reservedKeys = [
            "ad_activeview",
            "ad_click",
            "ad_exposure",
            "ad_impression",
            "ad_query",
            "adunit_exposure",
            "app_clear_data",
            "app_remove",
            "app_update",
            "error",
            "first_open",
            "in_app_purchase",
            "notification_dismiss",
            "notification_foreground",
            "notification_open",
            "notification_receive",
            "os_update",
            "screen_view",
            "session_start",
            "user_engagement"
        ]
    }

    // MARK: - Properties

    private let queue = DispatchQueue(label: "AnalyticsService", qos: .background)

    // MARK: Public Methods

    func trackEvent(title: String, parameters: [String: Any]?) {
        queue.async { [weak self] in
            guard let self else { return }
            guard !title.isEmpty, !isReservedKey(title) else { return }
            let title = String(title.prefix(FirebaseConstants.MaxLength.key))
            guard let parameters else {
                Analytics.logEvent(title, parameters: nil)
                return
            }
            let params = parameters
                .mapValues { value -> Any in
                    guard let valueString = value as? String else {
                        return value
                    }
                    return valueString.prefix(FirebaseConstants.MaxLength.value)
                }
            Analytics.logEvent(title, parameters: params)
        }
    }

    // MARK: Private methods

    private func isReservedKey(_ key: String) -> Bool {
        FirebaseConstants.reservedKeys.contains(key)
    }
}
