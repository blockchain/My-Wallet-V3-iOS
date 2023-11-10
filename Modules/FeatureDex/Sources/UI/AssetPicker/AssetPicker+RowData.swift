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
                    balance.currency
                case .token(let currency):
                    currency
                }
            }

            public var balance: DexBalance {
                switch self {
                case .balance(let balance):
                    balance
                case .token(let token):
                    .zero(token)
                }
            }

            public var id: String {
                switch self {
                case .balance(let balance):
                    "balance-\(balance.currency.code)"
                case .token(let currency):
                    "token-\(currency.code)"
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
    func filtered(by searchText: String) -> Self {
        filter { $0.currency.matchSearch(searchText) }
    }
}
