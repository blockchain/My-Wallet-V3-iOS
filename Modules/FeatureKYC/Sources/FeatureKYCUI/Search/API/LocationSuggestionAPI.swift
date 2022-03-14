// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

typealias LocationSuggestionCompletion = ([LocationSuggestion]?, Error?) -> Void
typealias PostalAddressCompletion = (PostalAddress) -> Void

protocol LocationSuggestionAPI {
    func search(for query: String, with completion: @escaping LocationSuggestionCompletion)
    func fetchAddress(from suggestion: LocationSuggestion, with block: @escaping PostalAddressCompletion)
    func cancel()

    var isExecuting: Bool { get }
}
