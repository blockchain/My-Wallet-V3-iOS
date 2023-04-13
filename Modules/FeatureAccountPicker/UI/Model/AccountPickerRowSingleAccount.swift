// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import SwiftUI

extension AccountPickerRow {

    public struct SingleAccount: Equatable, Identifiable {

        // MARK: - Public properties

        public let id: AnyHashable
        public let currency: String

        // MARK: - Internal properties

        var title: String
        var description: String

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

        // MARK: - Public Properties

        public var fiatBalance: LoadingState<String>
        public var cryptoBalance: LoadingState<String>

        // MARK: - Init

        public init(
            fiatBalance: LoadingState<String>,
            cryptoBalance: LoadingState<String>
        ) {
            self.fiatBalance = fiatBalance
            self.cryptoBalance = cryptoBalance
        }
    }
}
