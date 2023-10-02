// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import SwiftUI

extension AccountPickerRow {

    public struct SingleAccount: Equatable, Identifiable {

        // MARK: - Public properties

        public let id: AnyHashable
        public let currency: String

        // MARK: - Internal properties

        let title: String
        let description: String

        // MARK: - Init

        public init(
            id: AnyHashable,
            currency: String,
            title: String,
            description: String
        ) {
            self.id = id
            self.currency = currency
            self.title = title
            self.description = description
        }
    }
}

extension AccountPickerRow.SingleAccount {

    public struct Balances {

        public static let loading: Self = Self(fiatBalance: .loading, cryptoBalance: .loading)

        // MARK: - Public Properties

        let fiatBalance: LoadingState<String>
        let cryptoBalance: LoadingState<String>

        // MARK: - Init

        init(
            fiatBalance: LoadingState<String>,
            cryptoBalance: LoadingState<String>
        ) {
            self.fiatBalance = fiatBalance
            self.cryptoBalance = cryptoBalance
        }

        public init(
            fiatBalance: String,
            cryptoBalance: String
        ) {
            self.fiatBalance = .loaded(next: fiatBalance)
            self.cryptoBalance = .loaded(next: cryptoBalance)
        }
    }
}
