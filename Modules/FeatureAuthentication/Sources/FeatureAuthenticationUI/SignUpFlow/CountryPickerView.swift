// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation
import Localization
import SwiftUI
import UIComponentsKit

public struct CountryPickerView: View {

    private typealias LocalizedStrings = LocalizationConstants.Authentication.CountryAndStatePickers

    static let restrictedCountryIdentifiers: Set<String> = ["CU", "IR", "KP", "SY"]

    public static let countries: [SearchableItem<String>] = Locale.isoRegionCodes
        .filter { !restrictedCountryIdentifiers.contains($0) }
        .compactMap { code -> SearchableItem? in
            guard let countryName = Locale.current.localizedString(forRegionCode: code) else {
                return nil
            }
            return SearchableItem(
                id: code,
                title: countryName
            )
        }
        .sorted {
            $0.title.localizedCompare($1.title) == .orderedAscending
        }

    private let selectedItem: SearchableItem<String>?
    private let onSelection: (SearchableItem<String>) -> Void

    public init(
        selectedItem: SearchableItem<String>?,
        onSelection: @escaping (SearchableItem<String>) -> Void
    ) {
        self.selectedItem = selectedItem
        self.onSelection = onSelection
    }

    public var body: some View {
        SearchableItemPicker(
            sections: [
                .init(
                    title: LocalizedStrings.countriesSectionTitle,
                    items: CountryPickerView.countries
                )
            ],
            selectedItem: selectedItem,
            cancelButtonTitle: LocalizationConstants.searchCancelButtonTitle,
            searchPlaceholder: LocalizationConstants.searchPlaceholder,
            onSelection: onSelection
        )
    }
}
