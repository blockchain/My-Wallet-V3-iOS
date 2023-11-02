// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

extension Result {
    public var single: Single<Success> {
        switch self {
        case .success(let value):
            Single.just(value)
        case .failure(let error):
            Single.error(error)
        }
    }
}

extension Result {
    public var completable: Completable {
        switch self {
        case .success:
            Completable.empty()
        case .failure(let error):
            Completable.error(error)
        }
    }
}

extension SingleEvent {
    public static func error(_ error: Failure) -> Self {
        .failure(error)
    }
}
