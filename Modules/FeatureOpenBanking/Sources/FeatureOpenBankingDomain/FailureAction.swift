// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain

public protocol FailureAction {
    static func failure(_ error: OpenBanking.Error) -> Self
}

extension FailureAction {
    public static func failure(_ error: Error) -> Self { failure(.init(error)) }
}

extension Publisher where Output: ResultProtocol {

    @_disfavoredOverload
    public func map<T>(
        _ action: @escaping (Output.Success) -> T
    ) -> Publishers.Map<Self, T> where T: FailureAction {
        map { it -> T in
            switch it.result {
            case .success(let value):
                action(value)
            case .failure(let error):
                T.failure(error)
            }
        }
    }

    public func map<T>(
        _ action: CasePath<T, Output.Success>
    ) -> Publishers.Map<Self, T> where T: FailureAction {
        map { it -> T in
            switch it.result {
            case .success(let value):
                action.embed(value)
            case .failure(let error):
                T.failure(error)
            }
        }
    }
}
