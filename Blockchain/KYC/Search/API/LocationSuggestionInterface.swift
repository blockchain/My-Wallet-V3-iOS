//
//  LocationSuggestionInterface.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

protocol LocationSuggestionInterface: class {
    func updateActivityIndicator(_ visibility: Visibility)
    func primaryButton(_ visibility: Visibility)
    func suggestionsList(_ visibility: Visibility)
    func searchFieldActive(_ isFirstResponder: Bool)
    func searchFieldText(_ value: String?)
}
