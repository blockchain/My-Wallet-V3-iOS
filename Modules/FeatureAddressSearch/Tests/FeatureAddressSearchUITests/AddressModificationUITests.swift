// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
@testable import FeatureAddressSearchDomain
@testable import FeatureAddressSearchMock
@testable import FeatureAddressSearchUI
import Localization
import XCTest

final class AddressModificationReducerTests: XCTestCase {

    typealias TestStoreType = TestStore<
        AddressModificationState,
        AddressModificationAction,
        AddressModificationState,
        AddressModificationAction,
        ()
    >

    private var testStore: TestStoreType!
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    private let addressDetailsId: String? = AddressDetailsSearchResult.sample().addressId
    private let address: Address? = .sample()

    override func tearDown() {
        testStore = nil
        super.tearDown()
    }

    func test_on_view_appear_with_address_id_fetches_address_details() throws {
        testStore = .build(
            mainScheduler: mainScheduler,
            addressDetailsId: AddressDetailsSearchResult.sample().addressId
        )

        testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressEditScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
            $0.saveButtonTitle = sample.saveAddressButtonTitle
        }

        testStore.receive(.fetchAddressDetails(
            addressId: AddressDetailsSearchResult.sample().addressId)
        ) {
            $0.loading = true
        }

        mainScheduler.advance()

        testStore.receive(.didReceiveAdressDetailsResult(
            .success(.sample())
        )) {
            $0.loading = false
            let address = Address(addressDetails: .sample())
            $0.updateAddressInputs(address: address)
        }
    }

    func test_on_view_appear_with_address_id_fetches_address_details_states_does_not_match() throws {
        testStore = .build(
            mainScheduler: mainScheduler,
            addressDetailsId: AddressDetailsSearchResult.sample().addressId,
            country: "US",
            state: "MI"
        )

        testStore.send(.didReceiveAdressDetailsResult(.success(.sample(state: "ME"))))

        testStore.receive(.showStateDoesNotMatchAlert) {
            let loc = LocalizationConstants.AddressSearch.Form.Errors.self
            $0.failureAlert = AlertState(
                title: TextState(verbatim: loc.cannotEditStateTitle),
                message: TextState(verbatim: loc.cannotEditStateMessage),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    action: .send(.stateDoesNotMatch)
                )
            )
        }
    }

    func test_on_view_appear_without_address_prefills_address() throws {
        let address: Address = .sample()
        testStore = .build(
            mainScheduler: mainScheduler,
            addressDetailsId: nil,
            country: address.country,
            state: address.state,
            isPresentedFromSearchView: false
        )

        let state = testStore.state
        XCTAssertEqual(state.state, address.state)
        XCTAssertEqual(state.country, address.country)

        testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressEditScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
            $0.saveButtonTitle = sample.saveAddressButtonTitle
        }

        testStore.receive(.fetchPrefilledAddress) {
            $0.loading = true
        }

        mainScheduler.advance()

        testStore.receive(.didReceivePrefilledAddressResult(
            .success(address)
        )) {
            $0.loading = false
            $0.updateAddressInputs(address: .sample())
        }
    }

    func test_on_view_appear_with_address_and_with_search_it_does_not_prefetch_address() throws {
        let address: Address = .sample()
        testStore = .build(
            mainScheduler: mainScheduler,
            addressDetailsId: nil,
            country: address.country,
            state: address.state,
            isPresentedFromSearchView: true
        )

        let state = testStore.state
        XCTAssertEqual(state.state, address.state)
        XCTAssertEqual(state.country, address.country)
        XCTAssertEqual(state.line1, "")
        XCTAssertEqual(state.line2, "")
        XCTAssertEqual(state.city, "")
        XCTAssertEqual(state.postcode, "")

        testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressEditScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
            $0.saveButtonTitle = sample.saveAddressButtonTitle
        }
    }

    func test_on_save_updates_address() throws {
        let address: Address = .sample()
        testStore = .build(
            mainScheduler: mainScheduler,
            addressDetailsId: nil,
            country: address.country,
            state: address.state,
            isPresentedFromSearchView: false
        )

        testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressEditScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
            $0.saveButtonTitle = sample.saveAddressButtonTitle
        }

        testStore.receive(.fetchPrefilledAddress) {
            $0.loading = true
        }

        mainScheduler.advance()

        testStore.receive(.didReceivePrefilledAddressResult(
            .success(address)
        )) {
            $0.loading = false
            $0.updateAddressInputs(address: .sample())
        }

        testStore.send(.updateAddress) {
            $0.loading = true
        }

        mainScheduler.advance()

        testStore.receive(.updateAddressResponse(
            .success(address)
        )) {
            $0.loading = false
            $0.updateAddressInputs(address: .sample())
        }

        testStore.receive(.complete(
            .saved(address)
        ))
    }
}

extension TestStore {
    static func build(
        mainScheduler: TestSchedulerOf<DispatchQueue>,
        addressDetailsId: String? = "addressDetailsId",
        country: String? = nil,
        state: String? = nil,
        isPresentedFromSearchView: Bool = false
    ) -> AddressModificationReducerTests.TestStoreType {
        ComposableArchitecture.TestStore(
            initialState: AddressModificationState(
                addressDetailsId: addressDetailsId,
                country: country,
                state: state,
                isPresentedFromSearchView: isPresentedFromSearchView,
                error: nil
            ),
            reducer: AddressModificationReducer(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                config: .sample(),
                addressService: MockAddressService(),
                addressSearchService: MockAddressSearchService(),
                onComplete: { _ in }
            )
        )
    }
}
