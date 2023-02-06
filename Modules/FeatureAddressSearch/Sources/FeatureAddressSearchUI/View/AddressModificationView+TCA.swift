// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import Errors
import FeatureAddressSearchDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

enum AddressModificationAction: Equatable, BindableAction {

    case onAppear
    case updateAddress
    case fetchPrefilledAddress
    case didReceivePrefilledAddressResult(Result<Address?, AddressServiceError>)
    case updateAddressResponse(Result<Address, AddressServiceError>)
    case fetchAddressDetails(addressId: String?)
    case didReceiveAdressDetailsResult(Result<AddressDetailsSearchResult, AddressSearchServiceError>)
    case closeError
    case cancelEdit
    case showStateDoesNotMatchAlert
    case stateDoesNotMatch
    case showAlert(title: String, message: String)
    case dismissAlert
    case showGenericError
    case complete(AddressResult)
    case binding(BindingAction<AddressModificationState>)
}

struct AddressModificationState: Equatable {

    enum Field: Equatable {
        case line1, line2, city, state, zip
    }

    @BindableState var line1 = ""
    @BindableState var line2 = ""
    @BindableState var city = ""
    @BindableState var stateName = ""
    @BindableState var postcode = ""
    @BindableState var country = ""
    @BindableState var selectedInputField: Field?

    var state: String?
    var loading: Bool = false
    var addressDetailsId: String?
    var error: Nabu.Error?
    var isPresentedFromSearchView: Bool
    var shouldFetchPrefilledAddress: Bool
    var screenTitle: String = ""
    var screenSubtitle: String?
    var saveButtonTitle: String?
    var isStateFieldVisible: Bool { country == Address.Constants.usIsoCode }
    var failureAlert: AlertState<AddressModificationAction>?

    init(
        addressDetailsId: String? = nil,
        country: String? = nil,
        state: String? = nil,
        isPresentedFromSearchView: Bool,
        error: Nabu.Error? = nil
    ) {
        self.addressDetailsId = addressDetailsId
        self.isPresentedFromSearchView = isPresentedFromSearchView
        self.shouldFetchPrefilledAddress = !isPresentedFromSearchView
        self.error = error
        self.state = state
        self.stateName = state?.stateWithoutUSPrefix.map { usaStates[$0] ?? "" } ?? ""
        self.country = country ?? ""
    }

    init(
        address: Address,
        country: String? = nil,
        error: Nabu.Error? = nil
    ) {
        self.init(
            addressDetailsId: nil,
            country: address.country,
            state: address.state,
            isPresentedFromSearchView: false,
            error: error
        )
        updateAddressInputs(address: address)
    }
}

extension AddressModificationState {
    mutating func updateAddressInputs(address: Address) {
        selectedInputField = nil
        line1 = address.line1 ?? ""
        line2 = address.line2 ?? ""
        city = address.city ?? ""
        state = address.state
        stateName = state?.stateWithoutUSPrefix.map { usaStates[$0] ?? "" } ?? ""
        postcode = address.postCode ?? ""
        country = address.country ?? ""
    }
}

struct AddressModificationEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let config: AddressSearchFeatureConfig.AddressEditScreenConfig
    let addressService: AddressServiceAPI
    let addressSearchService: AddressSearchServiceAPI
    let onComplete: ((AddressResult) -> Void)?

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        config: AddressSearchFeatureConfig.AddressEditScreenConfig,
        addressService: AddressServiceAPI,
        addressSearchService: AddressSearchServiceAPI,
        onComplete: ((AddressResult) -> Void)? = nil
    ) {
        self.mainQueue = mainQueue
        self.config = config
        self.addressService = addressService
        self.addressSearchService = addressSearchService
        self.onComplete = onComplete
    }
}

let addressModificationReducer = Reducer<
    AddressModificationState,
    AddressModificationAction,
    AddressModificationEnvironment
> { state, action, env in

    switch action {
    case .updateAddress:
        state.loading = true
        let address = Address(
            line1: state.line1,
            line2: state.line2.isEmpty ? nil : state.line2,
            city: state.city,
            postCode: state.postcode,
            state: state.state,
            country: state.country
        )
        if env.config.shouldSaveAddressOnCompletion {
            return env
                .addressService
                .save(address: address)
                .receive(on: env.mainQueue)
                .catchToEffect(AddressModificationAction.updateAddressResponse)
        } else {
            return Effect(value: .updateAddressResponse(.success(address)))
        }

    case .updateAddressResponse(let result):
        state.loading = false
        switch result {
        case .success(let address):
            state.updateAddressInputs(address: address)
            return Effect(value: .complete(.saved(address)))
        case .failure(let error):
            state.error = error.nabuError
            return Effect(value: .showGenericError)
        }

    case .showGenericError:
        return Effect(
            value: .showAlert(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.AddressSearch.Form.Errors.genericError
            )
        )

    case .fetchAddressDetails(let addressId):
        guard let addressId else {
            return .none
        }
        state.loading = true
        return env
            .addressSearchService
            .fetchAddress(addressId: addressId)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map { result in
                .didReceiveAdressDetailsResult(result)
            }

    case .didReceiveAdressDetailsResult(let result):
        state.loading = false
        switch result {
        case .success(let searchedAddress):
            let address = Address(addressDetails: searchedAddress)
            if state.country == "US",
               let state = state.state,
               state.isNotEmpty,
               state != address.state
            {
                return Effect(value: .showStateDoesNotMatchAlert)
            } else {
                state.updateAddressInputs(address: address)
                return .none
            }

        case .failure(let error):
            state.error = error.nabuError
            return .none
        }

    case .onAppear:
        state.screenTitle = env.config.title
        state.screenSubtitle = env.config.subtitle
        state.saveButtonTitle = env.config.saveAddressButtonTitle

        guard let addressDetailsId = state.addressDetailsId else {
            if state.shouldFetchPrefilledAddress {
                return Effect(value: .fetchPrefilledAddress)
            } else {
                return .none
            }
        }
        return Effect(value: .fetchAddressDetails(addressId: addressDetailsId))

    case .fetchPrefilledAddress:
        state.loading = true
        return env
            .addressService
            .fetchAddress()
            .receive(on: env.mainQueue)
            .catchToEffect(AddressModificationAction.didReceivePrefilledAddressResult)

    case .didReceivePrefilledAddressResult(.success(let address)):
        state.loading = false
        guard let address else { return .none }
        state.updateAddressInputs(address: address)
        return .none

    case .didReceivePrefilledAddressResult(.failure(let error)):
        state.loading = false
        state.error = error.nabuError
        return .none

    case .closeError:
        state.error = nil
        return .none

    case .cancelEdit:
        return Effect(value: .complete(.abandoned))

    case .complete(let addressResult):
        return .fireAndForget {
            env.onComplete?(addressResult)
        }

    case .binding:
        return .none

    case .showAlert(let title, let message):
        state.failureAlert = AlertState(
            title: TextState(verbatim: title),
            message: TextState(verbatim: message),
            dismissButton: .default(
                TextState(LocalizationConstants.okString),
                action: .send(.dismissAlert)
            )
        )
        return .none

    case .dismissAlert:
        state.failureAlert = nil
        return .none

    case .showStateDoesNotMatchAlert:
        let loc = LocalizationConstants.AddressSearch.Form.Errors.self
        state.failureAlert = AlertState(
            title: TextState(verbatim: loc.cannotEditStateTitle),
            message: TextState(verbatim: loc.cannotEditStateMessage),
            dismissButton: .default(
                TextState(LocalizationConstants.okString),
                action: .send(.stateDoesNotMatch)
            )
        )
        return .none
    case .stateDoesNotMatch:
        return .none
    }
}
.binding()

extension Address {
    init(addressDetails: AddressDetailsSearchResult) {
        let line1 = [
            addressDetails.line1,
            addressDetails.line2,
            addressDetails.line3,
            addressDetails.line4,
            addressDetails.line5
        ]
            .compactMap { $0 }
            .filter(\.isNotEmpty)
            .joined(separator: ", ")
        self.init(
            line1: line1,
            line2: nil,
            city: addressDetails.city,
            postCode: addressDetails.postCode,
            state: addressDetails.state,
            country: addressDetails.country
        )
    }
}

extension String {
    var stateWithoutUSPrefix: String? {
        replacingOccurrences(
            of: Address.Constants.usPrefix,
            with: ""
        )
    }
}

extension AddressServiceError {
    var nabuError: Nabu.Error {
        switch self {
        case .network(let error):
            return error
        }
    }
}

private let usaStates: [String: String] = [
    "AK": "Alaska",
    "AL": "Alabama",
    "AR": "Arkansas",
    "AS": "American Samoa",
    "AZ": "Arizona",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DC": "District of Columbia",
    "DE": "Delaware",
    "FL": "Florida",
    "GA": "Georgia",
    "GU": "Guam",
    "HI": "Hawaii",
    "IA": "Iowa",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "MA": "Massachusetts",
    "MD": "Maryland",
    "ME": "Maine",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MO": "Missouri",
    "MS": "Mississippi",
    "MT": "Montana",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "NE": "Nebraska",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NM": "New Mexico",
    "NV": "Nevada",
    "NY": "New York",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "OR": "Oregon",
    "PA": "Pennsylvania",
    "PR": "Puerto Rico",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VA": "Virginia",
    "VI": "Virgin Islands",
    "VT": "Vermont",
    "WA": "Washington",
    "WI": "Wisconsin",
    "WV": "West Virginia",
    "WY": "Wyoming"
]
