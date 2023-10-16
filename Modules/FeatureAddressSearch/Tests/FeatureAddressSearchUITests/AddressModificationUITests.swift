// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
@testable import FeatureAddressSearchDomain
@testable import FeatureAddressSearchMock
@testable import FeatureAddressSearchUI
import Localization
import XCTest

@MainActor
final class AddressModificationReducerTests: XCTestCase {

    typealias TestStoreType = TestStore<
        AddressModificationState,
        AddressModificationAction
    >

    private var testStore: TestStoreType!
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    private let addressDetailsId: String? = AddressDetailsSearchResult.sample().addressId
    private let address: Address? = .sample()

    override func tearDown() {
        testStore = nil
        super.tearDown()
    }

    func test_on_view_appear_with_address_id_fetches_address_details() async throws {
        testStore = .build(
            mainScheduler: mainScheduler,
            addressDetailsId: AddressDetailsSearchResult.sample().addressId
        )

        await testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressEditScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
            $0.saveButtonTitle = sample.saveAddressButtonTitle
        }

        await testStore.receive(.fetchAddressDetails(
            addressId: AddressDetailsSearchResult.sample().addressId)
        ) {
            $0.loading = true
        }

        await mainScheduler.advance()

        await testStore.receive(.didReceiveAdressDetailsResult(
            .success(.sample())
        )) {
            $0.loading = false
            let address = Address(addressDetails: .sample())
            $0.updateAddressInputs(address: address)
        }
    }

    func test_on_view_appear_with_address_id_fetches_address_details_states_does_not_match() async throws {
        testStore = .build(
            mainScheduler: mainScheduler,
            addressDetailsId: AddressDetailsSearchResult.sample().addressId,
            country: "US",
            state: "MI"
        )

        await testStore.send(.didReceiveAdressDetailsResult(.success(.sample(state: "ME"))))

        await testStore.receive(.showStateDoesNotMatchAlert) {
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

    func test_on_view_appear_without_address_prefills_address() async throws {
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

        await testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressEditScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
            $0.saveButtonTitle = sample.saveAddressButtonTitle
        }

        await testStore.receive(.fetchPrefilledAddress) {
            $0.loading = true
        }

        await mainScheduler.advance()

        await testStore.receive(.didReceivePrefilledAddressResult(
            .success(address)
        )) {
            $0.loading = false
            $0.updateAddressInputs(address: .sample())
        }
    }

    func test_on_view_appear_with_address_and_with_search_it_does_not_prefetch_address() async throws {
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

        await testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressEditScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
            $0.saveButtonTitle = sample.saveAddressButtonTitle
        }
    }

    func test_on_save_updates_address() async throws {
        let address: Address = .sample()
        testStore = .build(
            mainScheduler: mainScheduler,
            addressDetailsId: nil,
            country: address.country,
            state: address.state,
            isPresentedFromSearchView: false
        )

        await testStore.send(.onAppear) {
            let sample = AddressSearchFeatureConfig.AddressEditScreenConfig.sample()
            $0.screenTitle = sample.title
            $0.screenSubtitle = sample.subtitle
            $0.saveButtonTitle = sample.saveAddressButtonTitle
        }

        await testStore.receive(.fetchPrefilledAddress) {
            $0.loading = true
        }

        await mainScheduler.advance()

        await testStore.receive(.didReceivePrefilledAddressResult(
            .success(address)
        )) {
            $0.loading = false
            $0.updateAddressInputs(address: .sample())
        }

        await testStore.send(.updateAddress) {
            $0.loading = true
        }

        await mainScheduler.advance()

        await testStore.receive(.updateAddressResponse(
            .success(address)
        )) {
            $0.loading = false
            $0.updateAddressInputs(address: .sample())
        }

        await testStore.receive(.complete(
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
            reducer: {
                AddressModificationReducer(
                    mainQueue: mainScheduler.eraseToAnyScheduler(),
                    config: .sample(),
                    addressService: MockAddressService(),
                    addressSearchService: MockAddressSearchService(),
                    onComplete: { _ in }
                )
            }
        )
    }
}
