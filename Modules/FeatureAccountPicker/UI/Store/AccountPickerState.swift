import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import Errors
import SwiftUI

public enum AccountPickerSection: Equatable, Identifiable {
    public var id: String {
        switch self {
        case .topMovers:
            return "top-movers"
        case .accounts(let rows):
            return rows.map { "\($0.id)" }.joined()
        }
    }

    case topMovers
    case accounts([AccountPickerRow])
}

public enum AccountPickerError: Error {
    case testError
}

public struct AccountPickerState: Equatable {
    typealias SectionState = LoadingState<Result<Sections, AccountPickerError>>

    var sections: SectionState
    var header: HeaderState

    var fiatBalances: [AnyHashable: String]
    var cryptoBalances: [AnyHashable: String]
    var currencyCodes: [AnyHashable: String]

    var prefetching = PrefetchingState(debounce: 0.25)
    var selected: AccountPickerRow.ID?
    var ux: UX.Dialog?
}

struct Sections: Equatable {
    let identifier = UUID()
    let content: [AccountPickerSection]
}

struct Rows: Equatable {
    let identifier = UUID()
    let content: [AccountPickerRow]

    /// In order to reduce expensive equality checks, content here is declared as a `let`, and
    /// the identifier is the only thing used for comparisons. This is okay since the content is only
    /// ever loaded once.
    static func == (lhs: Rows, rhs: Rows) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension AccountPickerState {
    struct HeaderState: Equatable {
        var headerStyle: HeaderStyle
        var searchText: String?
        var segmentControlSelection: Tag?
    }
}

extension AccountPickerState {
    struct Balances: Equatable {
        let fiat: String?
        let crypto: String?
        let currencyCode: String?
    }

    func balances(for identifier: AnyHashable) -> Balances {
        Balances(
            fiat: fiatBalances[identifier],
            crypto: cryptoBalances[identifier],
            currencyCode: currencyCodes[identifier]
        )
    }
}
