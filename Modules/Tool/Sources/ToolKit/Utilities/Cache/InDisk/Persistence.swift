// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import GRDB

extension AppDatabase {

    static func makeShared(id: String, reset: Bool) -> AppDatabase {
        let fileManager = FileManager()
        do {
            return try inDiskDB(fileManager: fileManager, id: id, reset: reset)
        } catch {
            switch error {
            case .SQLITE_FULL, .SQLITE_IOERR, .SQLITE_AUTH:
                print("InDisk Persistence did catch error: \(error)")
                return recover(fileManager:fileManager, id: id)
            default:
                fatalError("InDisk Persistence Unresolved error: \(error)")
            }
        }
    }

    private static func recover(fileManager: FileManager, id: String) -> AppDatabase {
        // Delete DB
        do {
            try deleteDB(fileManager: fileManager, id: id)
        } catch {
            print("Failed to delete item. \(error)")
        }

        // swiftlint:disable:next force_try
        return try! inMemoryDB()
    }

    private static func deleteDB(fileManager: FileManager, id: String) throws {
        let urls = try dbURLs(fileManager: fileManager, id: id)
        try fileManager.removeItem(at: urls.fileURL)
    }

    private static func dbURLs(fileManager: FileManager, id: String) throws -> (folderURL: URL, fileURL: URL) {
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
        let fileURL = folderURL.appendingPathComponent("\(id)-db.sqlite")
        return (folderURL, fileURL)
    }

    private static func inDiskDB(fileManager: FileManager, id: String, reset: Bool) throws -> AppDatabase {
        let urls = try dbURLs(fileManager: fileManager, id: id)

        // Support for tests: delete the database if requested
        if CommandLine.arguments.contains("-reset") || reset {
            try? fileManager.removeItem(at: urls.folderURL)
        }

        // Create the database folder if needed
        try fileManager.createDirectory(at: urls.folderURL, withIntermediateDirectories: true)

        let dbPool = try DatabasePool(path: urls.fileURL.path, configuration: configuration)

        // Create the AppDatabase
        let appDatabase = try AppDatabase(dbPool)

        return appDatabase
    }

    /// Creates an empty in-memory database.
    static func inMemoryDB() throws -> AppDatabase {
        let dbQueue = try DatabaseQueue()
        return try AppDatabase(dbQueue)
    }

    private static var configuration: Configuration {
        var config = Configuration()
#if DEBUG
        if logEnabled, BuildFlag.isInternal {
            config.prepareDatabase { db in
                // Prints all SQL statements
                db.trace { print("SQL >", $0) }
            }
            config.publicStatementArguments = true
        }
#endif
        return config
    }

    private static var logEnabled: Bool {
        false
    }
}
