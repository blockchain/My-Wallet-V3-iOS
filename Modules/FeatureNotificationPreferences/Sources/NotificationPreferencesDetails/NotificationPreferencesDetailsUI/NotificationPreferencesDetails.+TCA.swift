// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import FeatureNotificationPreferencesDomain
import Foundation

internal struct Switch: Equatable, Hashable {
    var method: NotificationMethod
    var isOn: Bool
}

public struct NotificationPreferencesDetailsState: Equatable, Hashable {
    public let notificationPreference: NotificationPreference
    @BindingState var pushSwitch: Switch = Switch(method: .push, isOn: false)
    @BindingState var emailSwitch: Switch = Switch(method: .email, isOn: false)
    @BindingState var smsSwitch: Switch = Switch(method: .sms, isOn: false)
    @BindingState var inAppSwitch: Switch = Switch(method: .inApp, isOn: false)
    @BindingState var browserSwitch: Switch = Switch(method: .browser, isOn: false)

    public init(notificationPreference: NotificationPreference) {
        self.notificationPreference = notificationPreference

        for methodInfo in notificationPreference.enabledMethods {
            switch methodInfo.method {
            case .email:
                emailSwitch.isOn = true
            case .inApp:
                inAppSwitch.isOn = true
            case .push:
                pushSwitch.isOn = true
            case .sms:
                smsSwitch.isOn = true
            case .browser:
                browserSwitch.isOn = true
            }
        }
    }

    public var updatedPreferences: UpdatedPreferences {
        let preferences = [pushSwitch, emailSwitch, smsSwitch, inAppSwitch]
            .filter { controlSwitch in
                let availableMethods = notificationPreference.allAvailableMethods.map(\.method)
                return availableMethods.contains(controlSwitch.method)
            }
            .map { UpdatedNotificationPreference(
                contactMethod: $0.method.rawValue,
                channel: notificationPreference.type.rawValue,
                action: $0.isOn ? "ENABLE" : "DISABLE"
            )
            }
        return UpdatedPreferences(preferences: preferences)
    }

    public var updatedAnalyticsEvent: AnalyticsEvent? {
        switch notificationPreference.type {

        case .transactional:
            return AnalyticsEvents
                .New
                .NotificationPreferenceDetailsEvents
                .walletActivitySetUp(
                    email: .init(emailSwitch.isOn),
                    in_app: .init(inAppSwitch.isOn),
                    push: .init(pushSwitch.isOn),
                    sms: .init(smsSwitch.isOn)
                )
        case .marketing:
            return AnalyticsEvents
                .New
                .NotificationPreferenceDetailsEvents
                .newsSetUp(
                    email: .init(emailSwitch.isOn),
                    in_app: .init(inAppSwitch.isOn),
                    push: .init(pushSwitch.isOn),
                    sms: .init(smsSwitch.isOn)
                )

        case .priceAlert:
            return AnalyticsEvents
                .New
                .NotificationPreferenceDetailsEvents
                .priceAlertsSetUp(
                    email: .init(emailSwitch.isOn),
                    in_app: .init(inAppSwitch.isOn),
                    push: .init(pushSwitch.isOn)
                )

        case .security:
            return AnalyticsEvents
                .New
                .NotificationPreferenceDetailsEvents
                .securityAlertsSetUp(
                    email: .init(emailSwitch.isOn),
                    in_app: .init(inAppSwitch.isOn),
                    push: .init(pushSwitch.isOn),
                    sms: .init(smsSwitch.isOn)
                )
        }
    }
}

public enum NotificationPreferencesDetailsAction: Equatable, BindableAction {
    case save
    case onAppear
    case binding(BindingAction<NotificationPreferencesDetailsState>)
}

public struct NotificationPreferencesDetailsEnvironment {
    public init() {}
}
