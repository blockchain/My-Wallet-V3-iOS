// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol SessionTokenRepositoryAPI: AnyObject {

    /// Streams `Bool` indicating whether a session token is currently cached in the repo
    var hasSessionToken: Single<Bool> { get }

    /// Streams the cached session token or `nil` if it is not cached
    var sessionToken: Single<String?> { get }

    /// Sets the session token
    func set(sessionToken: String) -> Completable

    /// Cleans the session token
    func cleanSessionToken() -> Completable
}

public extension SessionTokenRepositoryAPI {
    var hasSessionToken: Single<Bool> {
        sessionToken
            .map { token in
                guard let token = token else { return false }
                return !token.isEmpty
            }
    }
}
