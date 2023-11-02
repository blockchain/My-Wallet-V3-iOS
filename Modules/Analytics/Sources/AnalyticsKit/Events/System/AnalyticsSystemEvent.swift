// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum ClientEvent: AnalyticsEvent {

    public var type: AnalyticsEventType { .nabu }

    case clientError(
        id: String?,
        error: String,
        networkEndpoint: String? = nil,
        networkErrorCode: String? = nil,
        networkErrorDescription: String? = nil,
        networkErrorId: String? = nil,
        networkErrorType: String? = nil,
        source: String,
        title: String,
        action: String? = nil,
        category: [String] = []
    )
}

#if canImport(UIKit)

import UIKit

enum SystemEvent: AnalyticsEvent {

    case applicationBackgrounded
    case applicationCrashed
    case applicationInstalled(ApplicationSystemEventParamaters)
    case applicationOpened(ApplicationOpenedSystemEventParamaters)
    case applicationUpdated(ApplicationUpdatedSystemEventParamaters)
    case pushNotificationReceived(ApplicationPushNotificationParamaters)
    case pushNotificationTapped(ApplicationPushNotificationParamaters)
}

extension SystemEvent {

    var type: AnalyticsEventType { .nabu }

    static var applicationInstalled: SystemEvent {
        .applicationInstalled(.init())
    }

    static func applicationOpened(_ notification: Notification) -> SystemEvent {
        .applicationOpened(.init(notification: notification))
    }

    static var applicationUpdated: SystemEvent {
        .applicationUpdated(.init())
    }
}

private var systemEventAnalytics: SystemEventAnalytics?

extension SystemEventAnalytics {

    public static func start(
        notificationCenter: NotificationCenter = .default,
        userDefaults: UserDefaults = .standard,
        recordingOn recorder: AnalyticsEventRecorderAPI,
        didCrashOnPreviousExecution: @escaping () -> Bool
    ) {
        systemEventAnalytics = SystemEventAnalytics(
            notificationCenter: notificationCenter,
            userDefaults: userDefaults,
            recordingOn: recorder,
            didCrashOnPreviousExecution: didCrashOnPreviousExecution
        )
    }
}

public final class SystemEventAnalytics {

    let app = App()
    let userDefaults: UserDefaults
    let didCrashOnPreviousExecution: () -> Bool

    var bundle: Bundle = .main
    var bag: Set<AnyCancellable> = []

    init(
        notificationCenter: NotificationCenter = .default,
        userDefaults: UserDefaults = .standard,
        recordingOn recorder: AnalyticsEventRecorderAPI,
        didCrashOnPreviousExecution: @escaping () -> Bool
    ) {

        self.userDefaults = userDefaults
        self.didCrashOnPreviousExecution = didCrashOnPreviousExecution

        if userDefaults.string(forKey: ApplicationUpdatedSystemEventParamaters.installedVersion) == nil {
            userDefaults.set(app.version, forKey: ApplicationUpdatedSystemEventParamaters.installedVersion)
        }

        notificationCenter.publisher(for: UIApplication.didEnterBackgroundNotification)
            .replaceOutput(with: SystemEvent.applicationBackgrounded)
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .compactMap { _ in
                let update = ApplicationUpdatedSystemEventParamaters()
                guard update.previousVersion == nil else { return nil }
                return SystemEvent.applicationInstalled
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .map(SystemEvent.applicationOpened(_:))
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .compactMap { _ in
                let update = ApplicationUpdatedSystemEventParamaters()
                let isDifferent = !(update.version == update.previousVersion || update.build == update.previousBuild)
                guard update.previousVersion != nil, isDifferent else {
                    return nil
                }
                return SystemEvent.applicationUpdated
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .compactMap { [pushNotificationParameters] notification in
                SystemEvent.pushNotificationTapped(pushNotificationParameters(notification))
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .compactMap { [didCrashOnPreviousExecution] _ in
                guard didCrashOnPreviousExecution() else { return nil }
                return SystemEvent.applicationCrashed
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.willEnterForegroundNotification)
            .map(SystemEvent.applicationOpened)
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.willTerminateNotification)
            .sink(to: SystemEventAnalytics.willTerminate(notification:), on: self)
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.pushNotificationReceivedNotification)
            .compactMap { [pushNotificationParameters] notification in
                SystemEvent.pushNotificationReceived(pushNotificationParameters(notification))
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)
    }

    func pushNotificationParameters(notification: Notification) -> ApplicationPushNotificationParamaters {
        if
            let payload = notification.userInfo as? [String: Any]
        {
            .init(
                campaign_content: payload["body"] as? String,
                campaign_medium: payload["medium"] as? String,
                campaign_name: payload["title"] as? String,
                campaign_source: payload["source"] as? String,
                campaign_template: payload["template"] as? String
            )
        } else {
            .init()
        }
    }

    func willTerminate(notification: Notification) {
        userDefaults.set(app.version, forKey: ApplicationUpdatedSystemEventParamaters.previousVersion)
        userDefaults.set(app.build, forKey: ApplicationUpdatedSystemEventParamaters.previousBuild)
    }
}

public struct ApplicationSystemEventParamaters: AnalyticsEventParameters, Encodable {
    public let version: String
    public let build: String
}

public struct ApplicationPushNotificationParamaters: AnalyticsEventParameters, Encodable {
    public var campaign_content: String?
    public var campaign_medium: String?
    public var campaign_name: String?
    public var campaign_source: String?
    public var campaign_template: String?

    public init(
        campaign_content: String? = nil,
        campaign_medium: String? = "Push Notification",
        campaign_name: String? = nil,
        campaign_source: String? = nil,
        campaign_template: String? = nil
    ) {
        self.campaign_content = campaign_content
        self.campaign_medium = campaign_medium
        self.campaign_name = campaign_name
        self.campaign_source = campaign_source
        self.campaign_template = campaign_template
    }
}

extension ApplicationSystemEventParamaters {
    init(app: App = .init()) {
        self.version = app.version ?? "<unknown>"
        self.build = app.build ?? "<unknown>"
    }
}

public struct ApplicationOpenedSystemEventParamaters: AnalyticsEventParameters, Encodable {
    public let version: String
    public let build: String
    public let fromBackground: Bool
    public let referringApplication: String?
    public let url: String?
}

extension ApplicationOpenedSystemEventParamaters {

    init(app: App = .init(), notification: Notification) {
        self.version = app.version ?? "<unknown>"
        self.build = app.build ?? "<unknown>"
        self.fromBackground = notification.name == UIApplication.willEnterForegroundNotification
        self.referringApplication = notification.userInfo?[UIApplication.LaunchOptionsKey.sourceApplication] as? String
        self.url = notification.userInfo?[UIApplication.LaunchOptionsKey.url] as? String
    }
}

public struct ApplicationUpdatedSystemEventParamaters: AnalyticsEventParameters, Encodable {
    public let version: String
    public let build: String
    public let installedVersion: String?
    public let previousVersion: String?
    public let previousBuild: String?
}

extension ApplicationUpdatedSystemEventParamaters {

    static let installedVersion = "ApplicationUpdatedSystemEventParamaterInstalledVersion"
    static let previousVersion = "ApplicationUpdatedSystemEventParamaterPreviousVersion"
    static let previousBuild = "ApplicationUpdatedSystemEventParamaterPreviousBuild"

    init(app: App = .init(), userDefaults: UserDefaults = .standard) {
        self.version = app.version ?? "<unknown>"
        self.build = app.build ?? "<unknown>"
        self.installedVersion = userDefaults.string(forKey: Self.installedVersion)
        self.previousVersion = userDefaults.string(forKey: Self.previousVersion)
        self.previousBuild = userDefaults.string(forKey: Self.previousBuild)
    }
}

extension UIApplication {
    public static let pushNotificationReceivedNotification: NSNotification.Name = .init(rawValue: "UIApplicationPushNotificationReceivedNotification")
}

extension Publisher where Failure == Never {

    func replaceOutput<T>(with: T) -> Publishers.Map<Self, T> {
        map { _ in with }
    }

    func sink<Root>(
        to handler: @escaping (Root) -> (Output) -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { [weak root] value in
            guard let root else { return }
            handler(root)(value)
        }
    }
}

#endif
