// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import GRDB

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
}

extension AppDatabase {

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
}
