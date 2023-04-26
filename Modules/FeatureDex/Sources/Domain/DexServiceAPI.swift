// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import Dependencies
import Errors
import MoneyKit

public protocol DexServiceAPI {
    var balances: () -> AnyPublisher<Result<[DexBalance], UX.Error>, Never> { get }
    var quote: (DexQuoteInput) -> AnyPublisher<Result<DexQuoteOutput, UX.Error>, Never> { get }
    var receiveAddressProvider: (AppProtocol, CryptoCurrency) -> AnyPublisher<String, Error> { get }
}
