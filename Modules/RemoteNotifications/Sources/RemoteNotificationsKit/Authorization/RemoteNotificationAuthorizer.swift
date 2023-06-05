// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import Extensions
import SwiftUI
import ToolKit
import UIKit
import UserNotifications

final class RemoteNotificationAuthorizer {

    // MARK: - Private Properties

    private let application: UIApplicationRemoteNotificationsAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let userNotificationCenter: UNUserNotificationCenterAPI
    private let options: UNAuthorizationOptions

    // MARK: - Setup

    init(
        application: UIApplicationRemoteNotificationsAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        topMostViewControllerProvider: TopMostViewControllerProviding,
        userNotificationCenter: UNUserNotificationCenterAPI,
        options: UNAuthorizationOptions = [.alert, .badge, .sound]
    ) {
        self.application = application
        self.analyticsRecorder = analyticsRecorder
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.userNotificationCenter = userNotificationCenter
        self.options = options
    }

    // MARK: - Private Accessors

    private func requestAuthorization() -> AnyPublisher<Void, RemoteNotificationAuthorizerError> {
        Deferred { [analyticsRecorder, userNotificationCenter, options] ()
            -> AnyPublisher<Void, RemoteNotificationAuthorizerError> in
            AnyPublisher<Void, RemoteNotificationAuthorizerError>
                .just(())
                .handleEvents(
                    receiveOutput: { _ in
                        analyticsRecorder.record(
                            event: AnalyticsEvents.Permission.permissionSysNotifRequest
                        )
                    }
                )
                .flatMap {
                    userNotificationCenter
                        .requestAuthorizationPublisher(
                            options: options
                        )
                        .mapError(RemoteNotificationAuthorizerError.system)
                }
                .handleEvents(
                    receiveOutput: { isGranted in
                        let event: AnalyticsEvents.Permission
                        if isGranted {
                            event = .permissionSysNotifApprove
                        } else {
                            event = .permissionSysNotifDecline
                        }
                        analyticsRecorder.record(event: event)
                    }
                )
                .flatMap { isGranted -> AnyPublisher<Void, RemoteNotificationAuthorizerError> in
                    guard isGranted else {
                        return .failure(.permissionDenied)
                    }
                    return .just(())
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private var isNotDetermined: AnyPublisher<Bool, Never> {
        status
            .map { $0 == .notDetermined }
            .eraseToAnyPublisher()
    }
}

// MARK: - RemoteNotificationAuthorizationStatusProviding

extension RemoteNotificationAuthorizer: RemoteNotificationAuthorizationStatusProviding {
    var status: AnyPublisher<UNAuthorizationStatus, Never> {
        Deferred { [userNotificationCenter] in
            Future { [userNotificationCenter] promise in
                userNotificationCenter.getAuthorizationStatus { status in
                    promise(.success(status))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - RemoteNotificationRegistering

extension RemoteNotificationAuthorizer: RemoteNotificationRegistering {
    func registerForRemoteNotificationsIfAuthorized() -> AnyPublisher<Void, RemoteNotificationAuthorizerError> {
        isAuthorized
            .flatMap { isAuthorized -> AnyPublisher<Void, RemoteNotificationAuthorizerError> in
                guard isAuthorized else {
                    return .failure(.unauthorizedStatus)
                }
                return .just(())
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [unowned application] _ in
                    application.registerForRemoteNotifications()
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        Logger.shared
                            .error("Token registration failed with error: \(String(describing: error))")
                    case .finished:
                        break
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}

// MARK: - RemoteNotificationAuthorizing

extension RemoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting {

    public func displayPreAuthorization() -> AnyPublisher<Void, RemoteNotificationAuthorizerError> {
        Deferred { [topMostViewControllerProvider] in
            Future { [topMostViewControllerProvider] promise in
                guard let topMost = topMostViewControllerProvider.topMostViewController else {
                    promise(.failure(.unknowned))
                    return
                }
                let controller = UIHostingController(
                    rootView: RemoteNotificationAuthorizationView(
                        onEnableTap: {
                            topMost.dismiss(animated: true)
                            promise(.success(()))
                        },
                        onDisableTap: {
                            topMost.dismiss(animated: true)
                            promise(.failure(RemoteNotificationAuthorizerError.dismissed))
                        }
                    )
                )
                topMost.present(controller, animated: true)
            }
        }
        .eraseToAnyPublisher()
    }

    // TODO: Handle a `.denied` case
    func requestAuthorizationIfNeeded() -> AnyPublisher<Void, RemoteNotificationAuthorizerError> {
        isNotDetermined
            .flatMap { isNotDetermined -> AnyPublisher<Void, RemoteNotificationAuthorizerError> in
//                guard isNotDetermined else {
//                    return .failure(.statusWasAlreadyDetermined)
//                }
                return .just(())
            }
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .flatMap { [displayPreAuthorization] in
                displayPreAuthorization()
            }
            .flatMap { [requestAuthorization] in
                requestAuthorization()
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [unowned application] _ in
                    application.registerForRemoteNotifications()
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        Logger.shared
                            .error("Remote notification authorization failed with error: \(error)")
                    case .finished:
                        break
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}

extension AnalyticsEvents {
    enum Permission: AnalyticsEvent {
        case permissionSysNotifRequest
        case permissionSysNotifApprove
        case permissionSysNotifDecline

        var name: String {
            switch self {
            // Permission - remote notification system request
            case .permissionSysNotifRequest:
                return "permission_sys_notif_request"
            // Permission - remote notification system approve
            case .permissionSysNotifApprove:
                return "permission_sys_notif_approve"
            // Permission - remote notification system decline
            case .permissionSysNotifDecline:
                return "permission_sys_notif_decline"
            }
        }
    }
}
