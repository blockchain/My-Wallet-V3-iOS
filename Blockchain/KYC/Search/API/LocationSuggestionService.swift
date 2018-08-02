//
//  LocationSuggestionService.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import MapKit

class LocationSuggestionService: NSObject, LocationSuggestionAPI {

    fileprivate var completionHandler: LocationSuggestionCompletion!
    fileprivate let completer: MKLocalSearchCompleter

    override init() {
        completer = MKLocalSearchCompleter()
        completer.filterType = .locationsOnly
        super.init()
        completer.delegate = self
    }

    // MARK: LocationSuggestionAPI

    var isExecuting: Bool {
        get { return completer.isSearching }
    }

    func search(for query: String, with completion: @escaping LocationSuggestionCompletion) {
        if completer.isSearching && completer.queryFragment == query {
            return
        }

        completer.cancel()
        completionHandler = completion
        completer.queryFragment = query
    }

    func fetchAddress(from suggestion: LocationSuggestion, with block: @escaping PostalAddressCompletion) {
        let completion = completer.results.first(where: {$0.title == suggestion.title && $0.subtitle == suggestion.subtitle})
        guard let selection = completion else { return }

        let request = MKLocalSearchRequest(completion: selection)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard error == nil, let result = response else { return }
            guard let mapItem = result.mapItems.first else { return }
            
            let placemark = mapItem.placemark

            let postalAddress = PostalAddress(
                street: placemark.thoroughfare,
                streetNumber: placemark.subThoroughfare,
                postalCode: placemark.postalCode,
                country: placemark.country,
                countryCode: placemark.countryCode,
                city: placemark.locality,
                state: placemark.administrativeArea,
                unit: nil
            )
            block(postalAddress)
        }
    }

    func cancel() {
        completer.cancel()
        completionHandler = nil
    }
}

extension LocationSuggestionService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard let block = completionHandler else { return }
        let result = completer.results.map({ return LocationSuggestion(
            title: $0.title,
            subtitle: $0.subtitle,
            titleHighlights: $0.titleHighlightRanges.map({ return $0.rangeValue }),
            subtitleHighlights: $0.subtitleHighlightRanges.map({ return $0.rangeValue })
            )
        })
        block(result, nil)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        guard let block = completionHandler else { return }
        block(nil, error)
    }
}
