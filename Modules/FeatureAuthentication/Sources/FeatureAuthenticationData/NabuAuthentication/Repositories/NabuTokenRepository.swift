// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import ToolKit

final class NabuTokenRepository: NabuTokenRepositoryAPI {

    var sessionTokenPublisher: AnyPublisher<NabuSessionToken?, Never> {
        sessionTokenData.publisher
    }

    var sessionToken: String? {
        sessionTokenData.value?.token
    }

    var requiresRefresh: AnyPublisher<Bool, Never> {
        guard let value = sessionTokenData.value else {
            return .just(true)
        }
        return .just(value.isValid.isNo)
    }

    private let sessionTokenData = Atomic<NabuSessionToken?>(nil)

    init() {
        NotificationCenter.when(.logout) { [weak self] _ in
            self?.sessionTokenData.mutate { $0 = nil }
        }
    }

    func invalidate() -> AnyPublisher<Void, Never> {
        let sessionTokenData = sessionTokenData
        return Deferred {
            Future { [sessionTokenData] promise in
                sessionTokenData.mutate { $0 = nil }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func store(
        _ sessionToken: NabuSessionToken
    ) -> AnyPublisher<NabuSessionToken, Never> {
        let sessionTokenData = sessionTokenData
        return Deferred {
            Future { [sessionTokenData] promise in
                sessionTokenData.mutate { $0 = sessionToken }
                promise(.success(sessionToken))
            }
        }
        .eraseToAnyPublisher()
    }
}
