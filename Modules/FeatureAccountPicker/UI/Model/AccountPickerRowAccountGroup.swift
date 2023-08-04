// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import SwiftUI

extension AccountPickerRow {

    public struct AccountGroup: Equatable, Identifiable {

        // MARK: - Public Properties

        public let id: AnyHashable

        // MARK: - Internal Properties

        let title: String
        let description: String

        // MARK: - Init

        public init(
            id: AnyHashable,
            title: String,
            description: String
        ) {
            self.id = id
            self.title = title
            self.description = description
        }
    }
}

extension AccountPickerRow.AccountGroup {

    public struct Balances {

        public static let loading: Self = Self(fiatBalance: .loading, currencyCode: .loading)

        // MARK: - Public Properties

        let fiatBalance: LoadingState<String>
        let currencyCode: LoadingState<String>

        // MARK: - Init

        init(
            fiatBalance: LoadingState<String>,
            currencyCode: LoadingState<String>
        ) {
            self.fiatBalance = fiatBalance
            self.currencyCode = currencyCode
        }

        public init(
            fiatBalance: String,
            currencyCode: String
        ) {
            self.fiatBalance = .loaded(next: fiatBalance)
            self.currencyCode = .loaded(next: currencyCode)
        }
    }
}
