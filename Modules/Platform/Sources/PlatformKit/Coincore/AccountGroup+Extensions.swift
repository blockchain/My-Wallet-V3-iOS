// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension AccountGroup {

    public var activityStream: AnyPublisher<[ActivityItemEvent], Error> {
        accounts
            .compactMap { $0 as? BlockchainAccountActivity }
            .chunks(ofCount: 50)
            .map { accounts in
                accounts
                    .map { account in
                        account.activity
                            .replaceError(with: [ActivityItemEvent]())
                            .prepend([])
                            .eraseToAnyPublisher()
                    }
                    .combineLatest()
            }
            .combineLatest()
            .map { (result: [[[ActivityItemEvent]]]) -> [ActivityItemEvent] in
                result
                    .flatMap { $0 }
                    .flatMap { $0 }
                    .unique
                    .sorted(by: >)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }
}
