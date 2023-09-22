// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG
@testable import FeatureCryptoDomainData
import Combine
import Foundation
import NetworkKit

private struct SearchDomainClientMock: SearchDomainClientAPI {
    func getSearchResults(searchKey: String) -> AnyPublisher<SearchResultResponse, Errors.NetworkError> {
        var suggestions: [SuggestionResponse] = []
        for idx in 0...10 {
            let name = String(repeating: String(searchKey.first ?? "a"), count: idx)
            suggestions.append(SuggestionResponse(price: idx, name: name))
        }
        let value = SearchResultResponse(
            suggestions: suggestions,
            searchedDomain: SearchedDomainResponse(
                domain: SearchedDomainResponse.DomainResponse(name: searchKey),
                availability: SearchedDomainResponse.AvailabilityResponse(registered: false, protected: false, availableForFree: true)
            )
        )
        return .just(value)
    }

    func getFreeSearchResults(searchKey: String) -> AnyPublisher<FreeSearchResultResponse, Errors.NetworkError> {
        var suggestions: [SuggestionResponse] = []
        for idx in 1...10 {
            let name = String(repeating: String(searchKey.first ?? "a"), count: idx)
            suggestions.append(SuggestionResponse(price: 0, name: name))
        }
        let value = FreeSearchResultResponse(suggestions: suggestions)
        return .just(value)
    }
}

extension SearchDomainClient {

    static var mock: SearchDomainClientAPI { SearchDomainClientMock() }

    public static func test(
        _ requests: [URLRequest: Data] = [:]
    ) -> (
        client: SearchDomainClient,
        communicator: ReplayNetworkCommunicator
    ) {
        let communicator = ReplayNetworkCommunicator(requests, in: Bundle.module)
        return (
            SearchDomainClient(
                networkAdapter: NetworkAdapter(
                    communicator: communicator
                ),
                requestBuilder: RequestBuilder(
                    config: Network.Config(
                        scheme: "https",
                        host: "api.staging.blockchain.info"
                    )
                )
            ),
            communicator
        )
    }
}
#endif
