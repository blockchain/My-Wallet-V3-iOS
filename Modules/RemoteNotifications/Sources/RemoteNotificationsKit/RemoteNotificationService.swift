// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import ToolKit

/// A service that coordinates
final class RemoteNotificationService: RemoteNotificationServicing {

    // MARK: - ServiceError

    private enum ServiceError: Error {
        case unauthorizedRemoteNotificationsPermission
    }

    // MARK: - RemoteNotificationServicing (services)

    let authorizer: RemoteNotificationAuthorizing
    let backgroundReceiver: RemoteNotificationBackgroundReceiving
    let relay: RemoteNotificationEmitting

    // MARK: - Privately used services

    private let externalService: ExternalNotificationProviding
    private let iterableService: IterableServiceAPI
    private let networkService: RemoteNotificationNetworkServicing
    private let sharedKeyRepository: SharedKeyRepositoryAPI
    private let guidRepository: FeatureAuthenticationDomain.GuidRepositoryAPI

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Setup

    init(
        authorizer: RemoteNotificationAuthorizing,
        notificationRelay: RemoteNotificationEmitting,
        backgroundReceiver: RemoteNotificationBackgroundReceiving,
        externalService: ExternalNotificationProviding,
        iterableService: IterableServiceAPI,
        networkService: RemoteNotificationNetworkServicing,
        sharedKeyRepository: SharedKeyRepositoryAPI,
        guidRepository: FeatureAuthenticationDomain.GuidRepositoryAPI
    ) {
        self.authorizer = authorizer
        self.externalService = externalService
        self.iterableService = iterableService
        self.networkService = networkService
        self.sharedKeyRepository = sharedKeyRepository
        self.guidRepository = guidRepository
        self.relay = notificationRelay
        self.backgroundReceiver = backgroundReceiver
    }
}

// MARK: - RemoteNotificationTokenSending

extension RemoteNotificationService: RemoteNotificationTokenSending {
    func sendTokenIfNeeded() -> AnyPublisher<Void, RemoteNotificationTokenSenderError> {
        authorizer.isAuthorized
            .flatMap { [externalService] isAuthorized
                -> AnyPublisher<String, RemoteNotificationTokenSenderError> in
                guard isAuthorized else {
                    return .failure(.failed)
                }
                return externalService.token
                    .replaceError(with: RemoteNotificationTokenSenderError.failed)
                    .eraseToAnyPublisher()
            }
            .flatMap { [networkService, sharedKeyRepository, guidRepository] token
                -> AnyPublisher<Void, RemoteNotificationTokenSenderError> in
                networkService
                    .register(
                        with: token,
                        sharedKeyProvider: sharedKeyRepository,
                        guidProvider: guidRepository
                    )
                    .replaceError(with: RemoteNotificationTokenSenderError.failed)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - RemoteNotificationDeviceTokenReceiving

extension RemoteNotificationService: RemoteNotificationDeviceTokenReceiving {
    func appDidFailToRegisterForRemoteNotifications(with error: Error) {
        #if targetEnvironment(simulator)
        #else
        Logger.shared.info("Remote Notification Registration Failed with error: \(error)")
        #endif
    }

    func appDidRegisterForRemoteNotifications(with deviceToken: Data) {
        Logger.shared.info("Remote Notification Registration Succeeded")

        // FCM service must be informed about the new token
        externalService.didReceiveNewApnsToken(token: deviceToken)

        // update Iterable token for marketing push
        iterableService
            .updateToken(deviceToken.toHexString)
            .subscribe()
            .store(in: &cancellables)

        // Send the token
        sendTokenIfNeeded()
            .subscribe()
            .store(in: &cancellables)

        externalService
            .subscribe(to: .remoteConfig)
            .subscribe()
            .store(in: &cancellables)
    }
}
