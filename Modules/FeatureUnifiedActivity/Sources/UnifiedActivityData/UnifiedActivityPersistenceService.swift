// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import NetworkKit
import ToolKit
import UnifiedActivityDomain

final class UnifiedActivityPersistenceService: UnifiedActivityPersistenceServiceAPI {

    private let app: AppProtocol
    private let appDatabase: AppDatabaseAPI
    private var setupCancellables: Set<AnyCancellable> = []
    private var cancellables: Set<AnyCancellable> = []
    private let service: UnifiedActivityServiceAPI
    private let subject: PassthroughSubject<ActivityUpdate, Never> = .init()
    private let configuration: CacheConfiguration
    private let notificationCenter: NotificationCenter

    init(
        appDatabase: AppDatabaseAPI,
        service: UnifiedActivityServiceAPI,
        configuration: CacheConfiguration,
        notificationCenter: NotificationCenter,
        app: AppProtocol
    ) {
        self.app = app
        self.appDatabase = appDatabase
        self.service = service
        self.configuration = configuration
        self.notificationCenter = notificationCenter
        setupPersistence()
        setupCacheConfiguration()
    }

    private func setupPersistence() {
        subject
            .map { update -> ActivityDBUpdate in
                let entries = update.entries.compactMap { entry -> ActivityEntity? in
                    guard let data = try? JSONEncoder().encode(entry) else {
                        return nil
                    }
                    guard let json = String(data: data, encoding: .utf8) else {
                        return nil
                    }
                    return ActivityEntity(
                        identifier: entry.id,
                        json: json,
                        networkIdentifier: entry.network,
                        pubKey: entry.pubKey,
                        state: entry.state.rawValue,
                        timestamp: entry.timestamp
                    )
                }
                return ActivityDBUpdate(
                    updateType: update.updateType,
                    network: update.network,
                    pubKey: update.pubKey,
                    entries: entries
                )
            }
            .sink { [appDatabase] dbUpdate in
                try? appDatabase.applyDBUpdate(dbUpdate)
            }
            .store(in: &setupCancellables)
    }

    private func setupCacheConfiguration() {
        for flushNotificationName in configuration.flushNotificationNames {
            notificationCenter
                .publisher(for: flushNotificationName)
                .flatMap { [removeAll] _ in removeAll() }
                .subscribe()
                .store(in: &setupCancellables)
        }

        for flush in configuration.flushEvents {
            switch flush {
            case .notification(let event):
                app.on(event) { [weak self] _ in self?.flush() }
                    .subscribe()
                    .store(in: &setupCancellables)
            case .binding(let event):
                app.publisher(for: event)
                    .sink { [weak self] _ in _ = self?.flush() }
                    .store(in: &setupCancellables)
            }
        }
    }

    private func removeAll() -> AnyPublisher<Void, Never> {
        Deferred { [flush] () -> AnyPublisher<Void, Never> in
            .just(flush())
        }
        .eraseToAnyPublisher()
    }

    private func flush() {
        try? appDatabase.deleteAllActivityEntities()
    }

    func connect() {
        cancellables = []
        let stream = isEnabled
            .flatMap { [service] isEnabled -> AnyPublisher<WebSocketConnection.Event, Never> in
                guard isEnabled else {
                    return .empty()
                }
                return service.connect
            }
            .share()
        stream
            .compactMap { event -> WebSocketEvent? in
                switch event {
                case .received(.string(let string)):
                    do {
                        return try JSONDecoder().decode(WebSocketEvent.self, from: Data(string.utf8))
                    } catch {
                        print(error)
                        return nil
                    }
                case .received(.data):
                    return nil
                case .connected, .disconnected, .recoverFromURLSessionCompletionError:
                    return nil
                }
            }
            .compactMap(\.activityUpdate)
            .sink(receiveValue: { [subject] activityUpdate in
                subject.send(activityUpdate)
            })
            .store(in: &cancellables)

        stream
            .filter { $0 == .connected }
            .flatMap { [service] _ in
                service.subscribeToActivity
            }
            .subscribe()
            .store(in: &cancellables)
    }

    private var isEnabled: AnyPublisher<Bool, Never> {
        app
            .publisher(
                for: blockchain.app.configuration.app.superapp.v1.is.enabled,
                as: Bool.self
            )
            .prefix(1)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}

struct ActivityUpdate {
    enum UpdateType {
        case update
        case snapshot
    }

    let updateType: UpdateType
    let network: String
    let pubKey: String
    let entries: [ActivityEntry]
}

struct ActivityDBUpdate {
    let updateType: ActivityUpdate.UpdateType
    let network: String
    let pubKey: String
    let entries: [ActivityEntity]
}

extension WebSocketEvent {
    var activityUpdate: ActivityUpdate? {
        switch self {
        case .heartbeat:
            return nil
        case .update(let payload):
            return payload.activityUpdate(with: .update)
        case .snapshot(let payload):
            return payload.activityUpdate(with: .snapshot)
        }
    }
}

extension WebSocketEvent.Payload {
    func activityUpdate(with updateType: ActivityUpdate.UpdateType) -> ActivityUpdate {
        let network = data.network
        let pubKey = data.pubKey
        return ActivityUpdate(
            updateType: updateType,
            network: network,
            pubKey: pubKey,
            entries: data.activity.map { item in
                ActivityEntry(
                    network: network,
                    pubKey: pubKey,
                    item: item
                )
            }
        )
    }
}
