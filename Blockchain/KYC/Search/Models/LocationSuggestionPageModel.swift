//
//  LocationSuggestionPageModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct LocationSearchResult {
    enum SearchUIState {
        case loading
        case error(Error?)
        case success
        case empty
    }

    var state: SearchUIState = .empty
    var suggestions: [LocationSuggestion] = []
}

extension LocationSearchResult {
    static let empty = LocationSearchResult(
        state: .empty,
        suggestions: []
    )
}
