// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
@testable import FeatureAddressSearchDomain
@testable import FeatureAddressSearchMock
@testable import FeatureAddressSearchUI
import XCTest

final class AddressSearchReducerTests: XCTestCase {

    typealias TestStoreType = TestStore<
        AddressSearchState,
        AddressSearchAction,
        AddressSearchState,
        AddressSearchAction,
        ()
    >

    private var testStore: TestStoreType!
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    private let addressDetailsId: String? = AddressDetailsSearchResult.sample().addressId
    private let address: Address? = .sample()
    private let searchDebounceInMilliseconds = DispatchTimeInterval.milliseconds(
        AddressSearchDebounceInMilliseconds
    )

    override func tearDown() {
        testStore = nil
        super.tearDown()
    }

    func test_on_view_appear_with_no_address_does_not_start_search() throws {
        testStore = .build(
            mainScheduler: mainScheduler,
            address: nil
        )

        testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressEditScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle ?? ""
        }
    }

    func test_on_view_appear_with_address_starts_search() throws {
        let address: Address = .sample()
        testStore = .build(
            mainScheduler: mainScheduler,
            address: address
        )

        testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressSearchScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
        }

        testStore.receive(
            .searchAddresses(
                searchText: address.searchText,
                country: address.country
            )
        ) {
            $0.isSearchResultsLoading = true
        }

        mainScheduler.advance(by: .init(searchDebounceInMilliseconds))

        testStore.receive(
            .didReceiveAddressesResult(
                .success([.sample()])
            )
        ) {
            $0.isSearchResultsLoading = false
            $0.searchResults = [.sample()]
        }
    }

    func test_on_select_address_with_address_type_navigates_to_modify_view() throws {
        testStore = .build(
            mainScheduler: mainScheduler,
            address: nil
        )

        testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressSearchScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
        }

        let searchResult: AddressSearchResult = .sample(
            type: AddressSearchResult.AddressType.address.rawValue
        )
        testStore.send(.selectAddress(searchResult))

        testStore.receive(
            .modifySelectedAddress(addressId: searchResult.addressId)
        )

        testStore.receive(
            .navigate(to: .modifyAddress(selectedAddressId: searchResult.addressId, address: nil))
        ) {
            $0.route = RouteIntent(
                route: .modifyAddress(selectedAddressId: searchResult.addressId, address: nil),
                action: .navigateTo
            )
            $0.addressModificationState = .init(
                addressDetailsId: searchResult.addressId,
                country: nil,
                state: nil,
                isPresentedFromSearchView: true,
                error: nil
            )
        }
    }

    func test_on_select_address_with_not_address_type_searches_with_container_id() throws {
        let address: Address = .sample()
        testStore = .build(
            mainScheduler: mainScheduler,
            address: address
        )

        testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressSearchScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
        }

        testStore.receive(
            .searchAddresses(
                searchText: address.searchText,
                country: address.country
            )
        ) {
            $0.isSearchResultsLoading = true
        }

        mainScheduler.advance(by: .init(searchDebounceInMilliseconds))

        testStore.receive(
            .didReceiveAddressesResult(
                .success([.sample()])
            )
        ) {
            $0.isSearchResultsLoading = false
            $0.searchResults = [.sample()]
        }

        let searchResult: AddressSearchResult = .sample(
            type: "OTHER_TYPE"
        )
        testStore.send(.selectAddress(searchResult)) {
            let searchText = (searchResult.text ?? "") + " "
            $0.searchText = searchText
            $0.containerSearch = .init(
                containerId: searchResult.addressId,
                searchText: searchText
            )
        }

        mainScheduler.advance(by: .init(searchDebounceInMilliseconds))

        testStore.receive(
            .searchAddresses(
                searchText: testStore.state.searchText,
                country: address.country
            )
        ) {
            $0.isSearchResultsLoading = true
        }

        mainScheduler.advance(by: .init(searchDebounceInMilliseconds))

        testStore.receive(
            .didReceiveAddressesResult(
                .success([.sample()])
            )
        ) {
            $0.isSearchResultsLoading = false
            $0.searchResults = [.sample()]
        }
    }
}

extension TestStore {
    static func build(
        mainScheduler: TestSchedulerOf<DispatchQueue>,
        address: Address? = .sample(),
        isPresentedFromSearchView: Bool = false
    ) -> AddressSearchReducerTests.TestStoreType {
        .init(
            initialState: AddressSearchState(
                address: address,
                error: nil
            ),
            reducer: AddressSearchReducer(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                config: .sample(),
                addressService: MockAddressService(),
                addressSearchService: MockAddressSearchService(),
                onComplete: { _ in }
            )
        )
    }
}
