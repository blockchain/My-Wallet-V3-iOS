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

private typealias LocalizedString = LocalizationConstants.EnterFullInformation

struct EnterFullInformation: ReducerProtocol {

    enum InputField: String {
        case phone
        case dateOfBirth
    }

    enum VerificationResult: Equatable {
        case abandoned
        case failure
        case success(prefillInfo: PrefillInfo)
    }

    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let phoneVerificationService: PhoneVerificationServiceAPI
    let prefillInfoService: PrefillInfoServiceAPI
    let dismissFlow: (VerificationResult) -> Void

    init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        phoneVerificationService: PhoneVerificationServiceAPI,
        prefillInfoService: PrefillInfoServiceAPI,
        dismissFlow: @escaping (VerificationResult) -> Void
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.phoneVerificationService = phoneVerificationService
        self.prefillInfoService = prefillInfoService
        self.dismissFlow = dismissFlow
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case didDisappear
        case didEnteredBackground
        case didEnterForeground
        case startPhoneVerfication(phoneNumber: String)
        case onStartPhoneVerficationFetched(TaskResult<Void>)
        case restartPhoneVerfication
        case startPollingCheckPhoneVerfication
        case checkPhoneVerfication
        case onCheckPhoneVerficationFetched(TaskResult<PhoneVerification>)
        case startTimerOfRestartingPhoneVerication
        case decrementTimerOfRestartingPhoneVerication
        case fetchPrefillInfo
        case onPrefillInfoFetched(TaskResult<PrefillInfo>)
        case finishedWithError(NabuError?)
        case loadForm(phone: String?, dateOfBirth: Date?)
        case onClose
        case onContinue
        case onDismissError
        case cancelAllTimers
    }

    struct State: Equatable {
        enum Mode: Equatable {
            case info
            case verifyingPhone
            case restartingVerificationLoading
            case loading
            case error(UX.Error)
        }
        var title = LocalizedString.title
        var phoneNumber: String?
        var dateOfBirth: Date?
        var restartPhoneVerificationCountdown: TimeInterval = 0
        @BindableState var restartPhoneVerificationButtonTitle: String? =
        LocalizedString.Body.VerifyingPhone.resendSMSButton
        @BindableState var isRestartPhoneVerificationButtonDisabled = false

        @BindableState var form: Form = .init(
            header: .init(
                title: LocalizedString.Body.title,
                description: LocalizedString.Body.subtitle
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
        var isLoading: Bool { mode == .loading }
        var isVerifyingPhone: Bool { mode == .verifyingPhone }

        var mode: Mode = .info
    }

    struct CheckPhoneVerificationTimerIdentifier: Hashable {}
    struct RestartPhoneVerificationTimerIdentifier: Hashable {}

    private let timerFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .short
        return formatter
    }()

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .binding(\.$form):
                return .none

            case .onAppear:
                return Effect(value: .loadForm(phone: nil, dateOfBirth: nil))

            case .didDisappear:
                return Effect(value: .cancelAllTimers)

            case .didEnteredBackground:
                return .cancel(id: CheckPhoneVerificationTimerIdentifier())

            case .didEnterForeground:
                guard state.mode == .verifyingPhone else { return .none }
                return Effect(value: .startPollingCheckPhoneVerfication)

            case let .loadForm(phone, dateOfBirth):
                state.form = .init(
                    header: .init(
                        title: LocalizedString.Body.title,
                        description: LocalizedString.Body.subtitle
                    ),
                    nodes: FormQuestion.enterFullInformation(
                        phone: phone,
                        dateOfBirth: dateOfBirth
                    ),
                    blocking: true
                )
                return .none

            case .onContinue:
                guard state.isValidForm,
                      let phoneNumber: String = try? state.form.nodes.answer(id: InputField.phone.rawValue)
                else {
                    return .none
                }
                state.phoneNumber = phoneNumber
                state.dateOfBirth = try? state.form.nodes.answer(id: InputField.dateOfBirth.rawValue)
                state.mode = .loading
                return Effect(value: .startPhoneVerfication(phoneNumber: phoneNumber))

            case .startPhoneVerfication(let phoneNumber):
                return .task {
                    await .onStartPhoneVerficationFetched(
                        TaskResult {
                            try await phoneVerificationService.startInstantLinkPossession(
                                phoneNumber: phoneNumber
                            )
                        }
                    )
                }

            case .onStartPhoneVerficationFetched(.success):
                return .merge(
                    Effect(value: .startPollingCheckPhoneVerfication),
                    Effect(value: .startTimerOfRestartingPhoneVerication)
                )

            case .onStartPhoneVerficationFetched(.failure(let error)):
                return Effect(value: .finishedWithError(error as? NabuError))

            case .restartPhoneVerfication:
                guard let phoneNumber = state.phoneNumber else { return .none }
                state.mode = .restartingVerificationLoading
                return .merge(
                    Effect(value: .cancelAllTimers),
                    Effect(value: .startPhoneVerfication(phoneNumber: phoneNumber))
                )

            case .startPollingCheckPhoneVerfication:
                state.mode = .verifyingPhone
                return .merge(
                    Effect(value: .checkPhoneVerfication),
                    Effect.timer(
                        id: CheckPhoneVerificationTimerIdentifier(),
                        every: 5,
                        on: mainQueue
                    )
                    .map { _ in .checkPhoneVerfication }
                        .receive(on: mainQueue)
                        .eraseToEffect()
                )

            case .checkPhoneVerfication:
                guard state.isVerifyingPhone else { return .none }
                return .task {
                    await .onCheckPhoneVerficationFetched(
                        TaskResult {
                            try await phoneVerificationService.fetchInstantLinkPossessionStatus()
                        }
                    )
                }

            case .onCheckPhoneVerficationFetched(.success(let phoneVerification)):
                switch phoneVerification.status {
                case .verified:
                    return .merge(
                        Effect(value: .cancelAllTimers),
                        Effect(value: .fetchPrefillInfo)
                    )
                case .unverified:
                    return .none
                default:
                    return .none
                }

            case .onCheckPhoneVerficationFetched(.failure(let error)):
                return Effect(value: .finishedWithError(error as? NabuError))

            case .startTimerOfRestartingPhoneVerication:
                state.restartPhoneVerificationCountdown = 61
                return .merge(
                    Effect(value: .decrementTimerOfRestartingPhoneVerication),
                    Effect.timer(
                        id: RestartPhoneVerificationTimerIdentifier(),
                        every: 1,
                        on: mainQueue
                    )
                    .map { _ in .decrementTimerOfRestartingPhoneVerication }
                        .receive(on: mainQueue)
                        .eraseToEffect()
                )

            case .decrementTimerOfRestartingPhoneVerication:
                guard state.restartPhoneVerificationCountdown > 1 else {
                    state.isRestartPhoneVerificationButtonDisabled = false
                    state.restartPhoneVerificationButtonTitle =
                    LocalizedString.Body.VerifyingPhone.resendSMSButton
                    return .cancel(id: RestartPhoneVerificationTimerIdentifier())
                }
                state.isRestartPhoneVerificationButtonDisabled = true
                state.restartPhoneVerificationCountdown -= 1
                state.restartPhoneVerificationButtonTitle = String(
                    format: LocalizedString.Body.VerifyingPhone.resendSMSInTimeButton,
                    timerFormatter.string(from: state.restartPhoneVerificationCountdown) ?? ""
                )
                return .none

            case .onClose:
                return .fireAndForget {
                    dismissFlow(.abandoned)
                }

            case .onDismissError:
                return .fireAndForget {
                    dismissFlow(.failure)
                }

            case .fetchPrefillInfo:
                state.mode = .loading
                guard let dateOfBirth = state.dateOfBirth else { return .none }
                return .task {
                    await .onPrefillInfoFetched(
                        TaskResult {
                            try await prefillInfoService.getPrefillInfo(dateOfBirth: dateOfBirth)
                        }
                    )
                }

            case .onPrefillInfoFetched(.success(let prefillInfo)):
                return .fireAndForget {
                    dismissFlow(.success(prefillInfo: prefillInfo))
                }

            case .onPrefillInfoFetched(.failure(let error)):
                state.mode = .info
                return Effect(value: .finishedWithError(error as? NabuError))

            case .finishedWithError(let error):
                state.mode = .error(UX.Error(error: error))
                return .merge(
                    Effect(value: .cancelAllTimers),
                    .fireAndForget {
                        dismissFlow(.failure)
                    }
                )

            case .cancelAllTimers:
                return .merge(
                    .cancel(id: CheckPhoneVerificationTimerIdentifier()),
                    .cancel(id: RestartPhoneVerificationTimerIdentifier())
                )
            }
        }
    }
}

extension EnterFullInformation {

    static func preview(app: AppProtocol) -> EnterFullInformation {
        EnterFullInformation(
            app: app,
            mainQueue: .main,
            phoneVerificationService: NoPhoneVerificationService(),
            prefillInfoService: NoPrefillInfoService(),
            dismissFlow: { _ in }
        )
    }
}

final class NoPhoneVerificationService: PhoneVerificationServiceAPI {

    func startInstantLinkPossession(
        phoneNumber: String
    ) async throws -> Void? {
        nil
    }

    func fetchInstantLinkPossessionStatus() async throws -> PhoneVerification {
        .init(status: .verified)
    }
}
