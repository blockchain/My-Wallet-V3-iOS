// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import GRDB

extension AppDatabase {

    static func makeShared() -> AppDatabase {
        let fileManager = FileManager()
        do {
            return try inDiskDB(fileManager: fileManager)
        } catch {
            switch error {
            case .SQLITE_FULL, .SQLITE_IOERR, .SQLITE_AUTH:
                print("Persistence did catch error: \(error)")
                return recover(fileManager: fileManager)
            default:
                fatalError("Persistence Unresolved error: \(error)")
            }
        }
    }

    private static func recover(fileManager: FileManager) -> AppDatabase {
        // Delete DB
        do {
            try deleteDB(fileManager: fileManager)
        } catch {
            print("Failed to delete item. \(error)")
        }

        // swiftlint:disable:next force_try
        return try! inMemoryDB()
    }

    private static func deleteDB(fileManager: FileManager) throws {
        let folderURL = try folderURL(fileManager: fileManager)
        try fileManager.removeItem(at: folderURL)
    }

    private static func folderURL(fileManager: FileManager) throws -> URL {
        try fileManager
            .url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent(
                "unified-activity-database",
                isDirectory: true
            )

    }

    private static func inDiskDB(fileManager: FileManager) throws -> AppDatabase {
        let folderURL = try folderURL(fileManager: fileManager)

        // Support for tests: delete the database if requested
        if CommandLine.arguments.contains("-reset") {
            try? fileManager.removeItem(at: folderURL)
        }

        // Create the database folder if needed
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

        // Connect to a database on disk
        let dbURL = folderURL.appendingPathComponent("db.sqlite")
        let dbPool = try DatabasePool(path: dbURL.path)

        // Create the AppDatabase
        let appDatabase = try AppDatabase(dbPool)

        return appDatabase
    }

    /// Creates an empty in-memory database.
    static func inMemoryDB() throws -> AppDatabase {
        let dbQueue = try DatabaseQueue()
        return try AppDatabase(dbQueue)
    }
}
