// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import GRDB

struct InDiskEntity<T: Equatable & Codable>: Identifiable, Equatable, Codable, FetchableRecord, PersistableRecord {
    var id: String
    var value: T
    var lastRefresh: Date
}
