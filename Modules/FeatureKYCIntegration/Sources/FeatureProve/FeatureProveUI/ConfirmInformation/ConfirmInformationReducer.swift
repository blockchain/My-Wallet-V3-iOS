// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import Errors
import Extensions
import FeatureFormDomain
import FeatureProveDomain
import Localization
import ToolKit

public enum AddressSearchResult: Equatable {
    case abandoned
    case saved(Address)
}

public protocol AddressSearchFlowPresenterAPI {
    func openSearchAddressFlow(
        country: String,
        state: String?
    ) -> AnyPublisher<FeatureProveUI.AddressSearchResult, Never>

    func openEditAddressFlow(
        address: Address
    ) -> AnyPublisher<FeatureProveUI.AddressSearchResult, Never>
}

private typealias LocalizedString = LocalizationConstants.ConfirmInformation

struct ConfirmInformation: ReducerProtocol {

    enum InputField: String {
        case firstName
        case lastName
        case address
        case dateOfBirth
        case phone

        static func addressAnswerId(index: Int) -> String {
            "\(InputField.address.rawValue)-\(index)"
        }

        static var emptyAddressAnswerId: String {
            "\(InputField.address.rawValue)-empty"
        }
    }

    enum VerificationResult: Equatable {
        case success(confirmInfo: ConfirmInfo?)
        case failure(Nabu.ErrorCode)
        case abandoned
    }

    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let proveConfig: ProveConfig
    let confirmInfoService: ConfirmInfoServiceAPI
    let addressSearchFlowPresenter: AddressSearchFlowPresenterAPI
    let completion: (VerificationResult) -> Void

    init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        proveConfig: ProveConfig,
        confirmInfoService: ConfirmInfoServiceAPI,
        addressSearchFlowPresenter: AddressSearchFlowPresenterAPI,
        completion: @escaping (VerificationResult) -> Void
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.proveConfig = proveConfig
        self.confirmInfoService = confirmInfoService
        self.addressSearchFlowPresenter = addressSearchFlowPresenter
        self.completion = completion
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case loadForm
        case confirmInfo
        case onConfirmInfoFetched(TaskResult<ConfirmInfo?>)
        case handleError(NabuError?)
        case searchAddress
        case onAddressSearchCompleted(Result<AddressSearchResult, Never>)
        case editSelectedAddress
        case onEditSelectedAddressCompleted(Result<AddressSearchResult, Never>)
        case onClose
        case onContinue
        case onDismissError
        case onEmptyAddressFieldTapped
        case onEnterAddressManuallyTapped
        case onStartEditingSelectedAddress
    }

    struct State: Equatable {
        var title: String = LocalizedString.title
        var firstName: String?
        var lastName: String?
        var addresses: [Address]
        var selectedAddress: Address?
        var dateOfBirth: Date?
        var phone: String?

        @BindableState var form: Form = .init(
            header: .init(
                title: LocalizedString.Body.title,
                description: ""
            ),
            nodes: [],
            blocking: true
        )

        var isValidForm: Bool {
            guard !form.nodes.isEmpty else {
                return false
            }
            return form.nodes.isValidForm
        }

        var isLoading: Bool = false
        var conirmInfo: ConfirmInfo?
        var uxError: UX.Error?
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .binding(\.$form):
                return .none

            case .onAppear:
                return Effect(value: .loadForm)

            case .loadForm:
                state.form = .init(
                    header: .init(
                        title: LocalizedString.Body.title,
                        description: ""
                    ),
                    nodes: FormQuestion.confirmInformation(
                        firstName: state.firstName,
                        lastName: state.lastName,
                        addresses: state.addresses,
                        selectedAddress: state.selectedAddress,
                        dateOfBirth: state.dateOfBirth,
                        phone: state.phone
                    ),
                    blocking: true
                )
                return .none

            case .onContinue:
                guard state.isValidForm else {
                    return .none
                }

                return Effect(value: .confirmInfo)

            case .onClose:
                return .fireAndForget {
                    completion(.abandoned)
                }

            case .confirmInfo:
                if state.addresses.count > 1 {
                    state.selectedAddress = state
                        .addresses
                        .enumerated()
                        .first { index, _ in
                            (try? state.form.nodes.answer(id: InputField.addressAnswerId(index: index))) ?? false
                        }?
                        .element
                }
                guard
                    let firstName: String = try? state.form.nodes.answer(id: InputField.firstName.rawValue),
                    let lastName: String = try? state.form.nodes.answer(id: InputField.lastName.rawValue),
                    let dateOfBirth: Date = try? state.form.nodes.answer(id: InputField.dateOfBirth.rawValue),
                    let phone: String = try? state.form.nodes.answer(id: InputField.phone.rawValue),
                    var address = state.selectedAddress
                else {
                    return .none
                }
                address.state = address.correctedState
                let confirmInfo: ConfirmInfo = .init(
                    firstName: firstName,
                    lastName: lastName,
                    address: address,
                    dateOfBirth: dateOfBirth,
                    phone: phone
                )
                state.isLoading = true
                return .task {
                    await .onConfirmInfoFetched(
                        TaskResult {
                            try await confirmInfoService.confirmInfo(confirmInfo: confirmInfo)
                        }
                    )
                }

            case .onConfirmInfoFetched(.failure(let error)):
                state.isLoading = false
                return Effect(value: .handleError(error as? NabuError))

            case .onConfirmInfoFetched(.success(let conirmInfo)):
                state.isLoading = false
                state.conirmInfo = conirmInfo
                return .fireAndForget {
                    completion(.success(confirmInfo: conirmInfo))
                }

            case .searchAddress:
                return addressSearchFlowPresenter.openSearchAddressFlow(
                    country: proveConfig.country,
                    state: proveConfig.state
                )
                .receive(on: mainQueue)
                .catchToEffect()
                .map { result -> Action in
                        .onAddressSearchCompleted(result)
                }

            case .onAddressSearchCompleted(.success(let result)):
                switch result {
                case .abandoned:
                    return .none

                case .saved(let address):
                    state.selectedAddress = address
                    if !state.addresses.contains(address) {
                        state.addresses.insert(address, at: 0)
                    }
                    return Effect(value: .loadForm)
                }

            case .editSelectedAddress:
                guard let address = state.selectedAddress else { return .none }
                return addressSearchFlowPresenter.openEditAddressFlow(address: address)
                    .receive(on: mainQueue)
                    .catchToEffect()
                    .map { result -> Action in
                            .onEditSelectedAddressCompleted(result)
                    }

            case .onEditSelectedAddressCompleted(.success(let result)):
                switch result {
                case .abandoned:
                    return .none

                case .saved(let address):
                    state.selectedAddress = address
                    state.addresses = [address]
                    return Effect(value: .loadForm)
                }

            case .handleError(let error):
                if error?.code == .proveVerificationFailed {
                    return .fireAndForget {
                        completion(.failure(.proveVerificationFailed))
                    }
                } else {
                    state.uxError = UX.Error(error: error)
                    return .none
                }

            case .onDismissError:
                state.uxError = nil
                return .none

            case .onEmptyAddressFieldTapped:
                return Effect(value: .searchAddress)

            case .onStartEditingSelectedAddress:
                return Effect(value: .editSelectedAddress)

            case .onEnterAddressManuallyTapped:
                return Effect(value: .searchAddress)
            }
        }
    }
}

extension ConfirmInformation {

    static func preview(app: AppProtocol) -> ConfirmInformation {
        ConfirmInformation(
            app: app,
            mainQueue: .main,
            proveConfig: .init(country: "US"),
            confirmInfoService: NoConfirmInfoService(),
            addressSearchFlowPresenter: NoAddressSearchFlowPresenter(),
            completion: { _ in }
        )
    }
}

final class NoConfirmInfoService: ConfirmInfoServiceAPI {
    func confirmInfo(confirmInfo: ConfirmInfo) async throws -> ConfirmInfo {
        confirmInfo
    }
}

final class NoAddressSearchFlowPresenter: AddressSearchFlowPresenterAPI {
    func openSearchAddressFlow(country: String, state: String?) -> AnyPublisher<AddressSearchResult, Never> {
        .empty()
    }

    func openEditAddressFlow(address: FeatureProveDomain.Address) -> AnyPublisher<AddressSearchResult, Never> {
        .empty()
    }
}
