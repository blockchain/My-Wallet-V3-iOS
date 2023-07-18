// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureDexDomain
import MoneyKit
import SwiftExtensions
import SwiftUI

extension AssetPicker {

    public struct RowData: Equatable, Identifiable, Hashable {

        public enum Content: Equatable, Identifiable, Hashable {
            case balance(DexBalance)
            case token(CryptoCurrency)

            public var currency: CryptoCurrency {
                switch self {
                case .balance(let balance):
                    return balance.currency
                case .token(let currency):
                    return currency
                }
            }

            public var id: String {
                switch self {
                case .balance(let balance):
                    return "balance-\(balance.currency.code)"
                case .token(let currency):
                    return "token-\(currency.code)"
                }
            }
        }

        public var id: String { content.id }
        public let content: Content

        public var currency: CryptoCurrency {
            content.currency
        }
    }
}

extension [AssetPicker.RowData] {

    func filtered(
        by searchText: String,
        using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)
    ) -> Self {
        filter {
            $0.currency.filter(by: searchText, using: algorithm)
        }
    }
}
