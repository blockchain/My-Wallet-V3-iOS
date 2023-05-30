// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Combine

/// Interface for unique guid provider. This id is used to identify anonymous user.
public protocol GuidRepositoryAPI {
    var guid: String? { get }
}

public protocol TraitRepositoryAPI {
    var traits: [String: String] { get }
    var traitsDidChange: AnyPublisher<Void, Never> { get }
}
