// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import ComposableArchitecture
import ComposableNavigation
@testable import FeatureCryptoDomainData
@testable import FeatureCryptoDomainDomain
@testable import FeatureCryptoDomainMock
@testable import FeatureCryptoDomainUI
import NetworkKit
import OrderedCollections
import TestKit
import ToolKit
import XCTest

@MainActor
final class SearchCryptoDomainReducerTests: XCTestCase {

    private var mockMainQueue: ImmediateSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        SearchCryptoDomainState,
        SearchCryptoDomainAction
    >!
    private var searchClient: SearchDomainClientAPI!
    private var orderClient: OrderDomainClientAPI!
    private var searchDomainRepository: SearchDomainRepository!
    private var orderDomainRepository: OrderDomainRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        (searchClient, _) = SearchDomainClient.test()
        (orderClient, _) = OrderDomainClient.test()
        mockMainQueue = DispatchQueue.immediate
        searchDomainRepository = SearchDomainRepository(
            apiClient: searchClient
        )
        orderDomainRepository = OrderDomainRepository(
            apiClient: orderClient
        )
        testStore = TestStore(initialState: SearchCryptoDomain.State()) {
            SearchCryptoDomain(
                analyticsRecorder: MockAnalyticsRecorder(),
                externalAppOpener: ToLogAppOpener(),
                searchDomainRepository: searchDomainRepository,
                orderDomainRepository: orderDomainRepository,
                userInfoProvider: {
                    .just(
                        OrderDomainUserInfo(
                            nabuUserId: "mockUserId",
                            nabuUserName: "Firstname",
                            resolutionRecords: []
                        )
                    )
                }
            )
            .dependency(\.mainQueue, mockMainQueue.eraseToAnyScheduler())
        }
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockMainQueue = nil
        testStore = nil
    }

    func testInitialState() {
        let state = testStore.state
        XCTAssertEqual(state.searchText, "")
        XCTAssertEqual(state.searchResults, [])

        XCTAssertFalse(state.isSearchFieldSelected)
        XCTAssertFalse(state.isPremiumDomainBottomSheetShown)
        XCTAssertFalse(state.isSearchResultsLoading)

        XCTAssertTrue(state.isAlertCardShown)
        XCTAssertTrue(state.isSearchTextValid)

        XCTAssertNil(state.selectedPremiumDomain)
        XCTAssertNil(state.route)
        XCTAssertNil(state.checkoutState)
    }

    func test_on_appear_should_search_domains_by_firstname() async throws {
        let expectedResults = try searchDomainRepository
            .searchResults(searchKey: "Firstname", freeOnly: true)
            .wait()
        await testStore.send(.onAppear)
        await testStore.receive(.searchDomainsWithUsername)
        await testStore.receive(.searchDomains(key: "Firstname", freeOnly: true)) { state in
            state.isSearchResultsLoading = true
        }
        await testStore.receive(.didReceiveDomainsResult(.success(expectedResults), true)) { state in
            state.isSearchResultsLoading = false
            state.searchResults = expectedResults
        }
    }

    func test_empty_search_text_should_search_domains_by_username() async throws {
        let expectedResults = try searchDomainRepository
            .searchResults(searchKey: "Firstname", freeOnly: true)
            .wait()
        await testStore.send(.set(\.$searchText, ""))
        await testStore.receive(.searchDomains(key: "", freeOnly: false))
        await testStore.receive(.searchDomainsWithUsername)
        await testStore.receive(.searchDomains(key: "Firstname", freeOnly: true)) { state in
            state.isSearchResultsLoading = true
        }
        await testStore.receive(.didReceiveDomainsResult(.success(expectedResults), true)) { state in
            state.isSearchResultsLoading = false
            state.searchResults = expectedResults
        }
    }

    func test_valid_search_text_should_search_domains() async throws {
        let expectedResults = try searchDomainRepository
            .searchResults(searchKey: "Searchkey", freeOnly: false)
            .wait()
        await testStore.send(.set(\.$searchText, "Searchkey")) { state in
            state.isSearchTextValid = true
            state.searchText = "Searchkey"
        }
        await testStore.receive(.searchDomains(key: "Searchkey", freeOnly: false)) { state in
            state.isSearchResultsLoading = true
        }
        await testStore.receive(.didReceiveDomainsResult(.success(expectedResults), false)) { state in
            state.isSearchResultsLoading = false
            state.searchResults = expectedResults
        }
    }

    func test_invalid_search_text_should_not_search_domains() async {
        await testStore.send(.set(\.$searchText, "in.valid")) { state in
            state.isSearchTextValid = false
            state.searchText = "in.valid"
        }
    }

    func test_select_free_domain_should_go_to_checkout() async {
        let testDomain = SearchDomainResult(
            domainName: "free.blockchain",
            domainType: .free,
            domainAvailability: .availableForFree
        )
        await testStore.send(.selectFreeDomain(testDomain)) { state in
            state.selectedDomains = OrderedSet([testDomain])
        }
        await testStore.receive(.navigate(to: .checkout)) { state in
            state.route = RouteIntent(route: .checkout, action: .navigateTo)
            state.checkoutState = .init(
                selectedDomains: OrderedSet([testDomain])
            )
        }
    }

    func test_select_premium_domain_should_open_bottom_sheet() async throws {
        let expectedResult = try orderDomainRepository
            .createDomainOrder(
                isFree: false,
                domainName: "premium",
                resolutionRecords: nil
            )
            .wait()
        let testDomain = SearchDomainResult(
            domainName: "premium.blockchain",
            domainType: .premium,
            domainAvailability: .availableForPremiumSale(price: "50")
        )
        await testStore.send(.selectPremiumDomain(testDomain)) { state in
            state.selectedPremiumDomain = testDomain
        }
        await testStore.receive(.set(\.$isPremiumDomainBottomSheetShown, true)) { state in
            state.isPremiumDomainBottomSheetShown = true
        }
        await testStore.receive(.didSelectPremiumDomain(.success(expectedResult))) { state in
            state.selectedPremiumDomainRedirectUrl = expectedResult.redirectUrl ?? ""
        }
    }

    func test_remove_at_checkout_should_update_state() async {
        let testDomain = SearchDomainResult(
            domainName: "free.blockchain",
            domainType: .free,
            domainAvailability: .availableForFree
        )
        await testStore.send(.selectFreeDomain(testDomain)) { state in
            state.selectedDomains = OrderedSet([testDomain])
        }
        await testStore.receive(.navigate(to: .checkout)) { state in
            state.route = RouteIntent(route: .checkout, action: .navigateTo)
            state.checkoutState = .init(
                selectedDomains: OrderedSet([testDomain])
            )
        }
        await testStore.send(.checkoutAction(.removeDomain(testDomain))) { state in
            state.checkoutState?.selectedDomains = OrderedSet([])
            state.selectedDomains = OrderedSet([])
        }
        await testStore.receive(.checkoutAction(.set(\.$isRemoveBottomSheetShown, false)))
        await testStore.receive(.dismiss()) { state in
            state.route = nil
        }
    }
}
