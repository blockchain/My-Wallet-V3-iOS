// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension Publisher where Output: Collection, Output.Element: FiatAccount {

    public func filter(canPerform action: AssetAction) -> AnyPublisher<[Output.Element], Failure> {
        flatMap { accounts in
            Publishers.MergeMany(
                accounts.map { account -> AnyPublisher<Output.Element, Failure> in
                    account.can(perform: action)
                        .replaceError(with: false)
                        .compactMap { $0 ? account : nil }
                        .setFailureType(to: Failure.self)
                        .eraseToAnyPublisher()
                }
            )
            .collect()
        }
        .eraseToAnyPublisher()
    }
}
