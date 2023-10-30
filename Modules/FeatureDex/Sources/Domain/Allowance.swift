// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import ToolKit

public protocol DexAllowanceRepositoryAPI {
    func fetch(
        address: String,
        currency: CryptoCurrency,
        allowanceSpender: String
    ) -> AnyPublisher<DexAllowanceOutput, Error>
    func poll(
        address: String,
        currency: CryptoCurrency,
        allowanceSpender: String
    ) -> AnyPublisher<DexAllowanceOutput, Error>
}

public struct DexAllowanceOutput: Equatable {

    public let currency: CryptoCurrency
    public let address: String
    public let allowance: String

    public var isOK: Bool {
        allowance.isNotEmpty && allowance != "0"
    }

    public init(currency: CryptoCurrency, address: String, allowance: String) {
        self.currency = currency
        self.address = address
        self.allowance = allowance
    }
}

public enum DexAllowanceResult: Equatable {
    case ok
    case nok(allowanceSpender: String)
}
