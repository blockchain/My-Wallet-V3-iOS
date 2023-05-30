// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxRelay
import RxSwift

public final class SearchController: UISearchController {

    public var text: Observable<String> {
        relay.asObservable()
    }

    private let relay = PublishRelay<String>()

    public init(placeholderText: String) {
        super.init(nibName: nil, bundle: nil)
        searchResultsUpdater = self
        searchBar.placeholder = placeholderText
        searchBar.showsCancelButton = false
        searchBar.tintColor = .semantic.text
        searchBar.backgroundColor = .semantic.background
        searchBar.isTranslucent = false
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        relay.accept(searchController.searchBar.text ?? "")
    }
}
