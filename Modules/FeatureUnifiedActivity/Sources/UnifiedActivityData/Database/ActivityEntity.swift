// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import GRDB
import UnifiedActivityDomain

struct ActivityEntity: Identifiable, Equatable, Codable, FetchableRecord, PersistableRecord {
    var id: String { "\(networkIdentifier)/\(identifier)" }
    let identifier: String
    let json: String
    let networkIdentifier: String
    let pubKey: String
    let state: String
    let timestamp: TimeInterval
}
