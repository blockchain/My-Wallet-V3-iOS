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
    private let subject: PassthroughSubject<[ActivityEntry], Never> = .init()
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
            .map { entries -> [ActivityEntity] in
                entries.compactMap { entry -> ActivityEntity? in
                    guard let data = try? JSONEncoder().encode(entry) else {
                        return nil
                    }
                    guard let json = String(data: data, encoding: .utf8) else {
                        return nil
                    }
                    return ActivityEntity(identifier: entry.id, json: json, networkIdentifier: entry.network, timestamp: entry.timestamp)
                }
            }
            .sink { [appDatabase] activities in
                try? appDatabase.saveActivityEntities(activities)
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
                case .connected, .disconnected:
                    return nil
                }
            }
            .compactMap { event -> WebSocketEvent.Payload? in
                switch event {
                case .heartbeat:
                    return nil
                case .update(let payload), .snapshot(let payload):
                    return payload
                }
            }
            .map(\.data)
            .map { data in
                data.activity.map { item in
                    ActivityEntry(network: data.network, pubKey: data.pubKey, item: item)
                }
            }
            .sink(receiveValue: { [subject] items in
                subject.send(items)
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
        guard BuildFlag.isInternal else {
            return .just(false)
        }
        return app
            .publisher(for: blockchain.app.configuration.app.superapp.v1.is.enabled, as: Bool.self)
            .prefix(1)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
