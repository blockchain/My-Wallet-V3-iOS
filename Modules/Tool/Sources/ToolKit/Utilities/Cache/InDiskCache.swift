// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Extensions
import Foundation
import GRDB
import GRDBQuery

/// An in-memory cache implementation.
public final class InDiskCache<AKey: Hashable & CustomStringConvertible, Value: Equatable & Codable>: CacheAPI {
    public typealias Key = AKey

    private let appDatabase: AppDatabase

    private let refreshControl: CacheRefreshControl

    private var cancellables = Set<AnyCancellable>()

    public let source: (file: String, line: Int)

    // MARK: - Setup

    /// Creates an in-memory cache.
    ///
    /// - Parameters:
    ///   - configuration:  A cache configuration.
    ///   - refreshControl: A cache refresh control.
    public convenience init(
        id: String,
        configuration: CacheConfiguration,
        refreshControl: CacheRefreshControl,
        notificationCenter: NotificationCenter = .default,
        file: String = #fileID,
        line: Int = #line
    ) {
        var isInTest: Bool { NSClassFromString("XCTestCase") != nil }
        self.init(
            appDatabase: AppDatabase.makeShared(id: id, reset: false),
            configuration: configuration,
            refreshControl: refreshControl,
            notificationCenter: notificationCenter,
            app: isInTest ? App.preview : DIKit.resolve(),
            file: file,
            line: line
        )
    }

    /// Creates an in-memory cache.
    ///
    /// - Parameters:
    ///   - configuration:  A cache configuration.
    ///   - refreshControl: A cache refresh control.
    init(
        appDatabase: AppDatabase,
        configuration: CacheConfiguration,
        refreshControl: CacheRefreshControl,
        notificationCenter: NotificationCenter = .default,
        app: AppProtocol,
        file: String = #fileID,
        line: Int = #line
    ) {
        self.appDatabase = appDatabase
        self.refreshControl = refreshControl
        self.source = (file, line)

        for flushNotificationName in configuration.flushNotificationNames {
            notificationCenter
                .publisher(for: flushNotificationName)
                .sink { [weak self] _ in self?.flush() }
                .store(in: &cancellables)
        }

        for flush in configuration.flushEvents {
            switch flush {
            case .notification(let event):
                app.on(event)
                    .sink { [weak self] _ in self?.flush() }
                    .store(in: &cancellables)
            case .binding(let event):
                app.publisher(for: event)
                    .sink { [weak self] _ in _ = self?.flush() }
                    .store(in: &cancellables)
            }
        }
    }

    public func get(key: Key) -> AnyPublisher<CacheValue<Value>, Never> {
        Deferred { [appDatabase, toCacheValue] () -> AnyPublisher<CacheValue<Value>, Never> in
            let cacheItem = try? appDatabase.dbReader
                .read(InDiskEntityRequest<Value>(id: key.description).fetchValue)
            let cacheValue = toCacheValue(cacheItem)
            return .just(cacheValue)
        }
        .eraseToAnyPublisher()
    }

    public func stream(key: Key) -> AnyPublisher<CacheValue<Value>, Never> {
        InDiskEntityRequest<Value>(id: key.description)
            .publisher(in: appDatabase)
            .subscribe(on: DispatchQueue.main)
            .removeDuplicates()
            .map(toCacheValue)
            .share()
            .replaceError(with: .absent)
            .eraseToAnyPublisher()
    }

    public func set(_ value: Value, for key: Key) -> AnyPublisher<Value?, Never> {
        Deferred { [appDatabase] () -> AnyPublisher<Value?, Never> in
            let oldItem = try? appDatabase.dbReader
                .read(InDiskEntityRequest<Value>(id: key.description).fetchValue)
            let entity = InDiskEntity(id: key.description, value: value, lastRefresh: Date())
            do {
                try appDatabase.dbWriter.write { db in
                    try entity.save(db)
                }
            } catch {
                print("error: \(error)")
            }
            return .just(oldItem?.first?.value)
        }
        .eraseToAnyPublisher()
    }

    public func remove(key: Key) -> AnyPublisher<Value?, Never> {
        Deferred { [appDatabase] () -> AnyPublisher<Value?, Never> in
            let oldItem = try? appDatabase.dbReader
                .read(InDiskEntityRequest<Value>(id: key.description).fetchValue)
            let entity = oldItem?.first
            try? appDatabase.dbWriter.write { db in
                _ = try? entity?.delete(db)
            }
            return .just(entity?.value)
        }
        .eraseToAnyPublisher()
    }

    public func removeAll() -> AnyPublisher<Void, Never> {
        Deferred { [appDatabase] () -> AnyPublisher<Void, Never> in
            .just(appDatabase.deleteAll())
        }
        .eraseToAnyPublisher()
    }

    private func flush() {
        refreshControl.invalidate()
    }

    // MARK: - Private Methods

    /// Maps the given cache item to a cache value.
    ///
    /// - Parameter cacheItem: A cache item.
    ///
    /// - Returns: A cache value.
    private func toCacheValue(_ cacheItem: [InDiskEntity<Value>]?) -> CacheValue<Value> {
        guard let item = cacheItem?.first else {
            return .absent
        }

        if refreshControl.shouldRefresh(lastRefresh: item.lastRefresh) {
            return .stale(item.value)
        }

        return .present(item.value)
    }
}

struct InDiskEntity<T: Equatable & Codable>: Identifiable, Equatable, Codable, FetchableRecord, PersistableRecord {
    var id: String
    var value: T
    var lastRefresh: Date
}

struct InDiskEntityRequest<T: Equatable & Codable>: Queryable {

    // MARK: - Queryable Implementation

    static var defaultValue: [InDiskEntity<T>] { [] }

    var id: String

    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[InDiskEntity<T>], Error> {
        // Build the publisher from the general-purpose read-only access granted by `appDatabase.databaseReader`.
        // Some apps will prefer to call a dedicated method of `appDatabase`.
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(
                in: appDatabase.dbReader,
                // The `.immediate` scheduling feeds the view right on
                // subscription, and avoids an undesired animation when the
                // application starts.
                scheduling: .immediate
            )
            .eraseToAnyPublisher()
    }

    // This method is not required by Queryable, but it makes it easier
    // to test PlayerRequest.
    func fetchValue(_ db: Database) throws -> [InDiskEntity<T>] {
        try InDiskEntity<T>
            .filter(id: id)
            .fetchAll(db)
    }
}

struct AppDatabase {
    /// Provides a read-only access to the database
    var dbReader: DatabaseReader {
        dbWriter
    }

    let dbWriter: any DatabaseWriter

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.eraseDatabaseOnSchemaChange = true
        migrator.registerMigration("v1") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "inDiskEntity") { t in
                t.column("id", .blob).notNull().primaryKey()
                t.column("value", .blob).notNull()
                t.column("lastRefresh", .date).notNull()
            }
        }
        return migrator
    }

    /// Creates an `AppDatabase`, and make sure the database schema is ready.
    init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }

    /// Deletes all entries from the common table
    func deleteAll() {
        DispatchQueue.global().async {
            do {
                try dbWriter.write { db in
                    try db.execute(literal: "DELETE from inDiskEntity")
                }
            } catch {
                print(error)
            }
        }
    }

    static func makeShared(id: String, reset: Bool) -> AppDatabase {
        do {
            let fileManager = FileManager()
            let folderURL = try fileManager
                .url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                .appendingPathComponent(
                    "inDiskEntity",
                    isDirectory: true
                )

            // Support for tests: delete the database if requested
            if CommandLine.arguments.contains("-reset") || reset {
                try? fileManager.removeItem(at: folderURL)
            }

            // Create the database folder if needed
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

            // Connect to a database on disk
            // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
            let dbURL = folderURL.appendingPathComponent("\(id)-db.sqlite")

            var config = Configuration()
            if logEnabled {
                config.prepareDatabase { db in
                    // Prints all SQL statements
                    db.trace { print("SQL >", $0) }
                }
                config.publicStatementArguments = true
            }

            let dbPool = try DatabasePool(path: dbURL.path, configuration: config)

            // Create the AppDatabase
            let appDatabase = try AppDatabase(dbPool)
            return appDatabase
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }

    /// Creates an empty database for SwiftUI previews
    static func empty() -> AppDatabase {
        // Connect to an in-memory database
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
        let dbQueue = try! DatabaseQueue()
        return try! AppDatabase(dbQueue)
    }

    private static var logEnabled: Bool {
        false
    }
}
