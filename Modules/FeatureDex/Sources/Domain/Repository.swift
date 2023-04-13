// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol DexVenuesRepositoryAPI {

    func venues() -> AnyPublisher<[Venue], Error>
}

public protocol DexChainsRepositoryAPI {

    func chains() -> AnyPublisher<[Chain], Error>
}

public protocol DexTokensRepositoryAPI {

    func tokens() -> AnyPublisher<[Token], Error>
}
