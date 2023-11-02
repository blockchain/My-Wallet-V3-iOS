// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit

struct CryptoExchangeAddressResponse: Decodable, Equatable {

    // MARK: - Types

    /// Error to be thrown in case decoding is unsuccessful
    enum ResponseError: Error {
        case assetType
        case state
        case address
    }

    /// State of Exchange account linking
    enum State: String, Equatable {
        case pending = "PENDING"
        case active = "ACTIVE"
        case blocked = "BLOCKED"

        /// Returns `true` for an active state
        var isActive: Bool {
            switch self {
            case .active:
                true
            case .pending, .blocked:
                false
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case state
        case currency
        case address
    }

    /// The asset type
    let assetType: CryptoCurrency

    /// The address associated with the asset type
    let address: String

    /// Thr state of the account
    let state: State

    // MARK: - Setup

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try values.decode(String.self, forKey: .address)
        guard !address.isEmpty else {
            throw ResponseError.address
        }

        let currency = try values.decode(String.self, forKey: .currency)
        let provider: EnabledCurrenciesServiceAPI = resolve()
        if let assetType = provider.allEnabledCryptoCurrencies.first(where: { $0.code == currency }) {
            self.assetType = assetType
        } else {
            throw ResponseError.assetType
        }
        let stateRawValue = try values.decode(String.self, forKey: .state)
        if let state = State(rawValue: stateRawValue) {
            self.state = state
        } else {
            throw ResponseError.state
        }
    }
}
