//
//  LocationSuggestionInterface.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

protocol LocationSuggestionInterface: class {
    func updateActivityIndicator(_ visibility: Visibility)
    func suggestionsList(_ visibility: Visibility)
    func addressEntryView(_ visibility: Visibility)
    func primaryButtonEnabled(_ enabled: Bool)
    func primaryButton(_ visibility: Visibility)
    func primaryButtonActivityIndicator(_ visibility: Visibility)
    func populateAddressEntryView(_ address: PostalAddress)
    func searchFieldActive(_ isFirstResponder: Bool)
    func searchFieldText(_ value: String?)
}
