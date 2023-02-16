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

    enum Constants {
        static let preferencesRestartVerificationCountdownKey = "enterFullInformation.restartVerificationCountdownKey"
    }

    enum InputField: String {
        case phone
        case dateOfBirth
    }

    enum VerificationResult: Equatable {
        case success(prefillInfo: PrefillInfo)
        case failure(Nabu.ErrorCode)
        case abandoned
    }

    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let phoneVerificationService: PhoneVerificationServiceAPI
    let prefillInfoService: PrefillInfoServiceAPI
    let completion: (VerificationResult) -> Void

    init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        phoneVerificationService: PhoneVerificationServiceAPI,
        prefillInfoService: PrefillInfoServiceAPI,
        completion: @escaping (VerificationResult) -> Void
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.phoneVerificationService = phoneVerificationService
        self.prefillInfoService = prefillInfoService
        self.completion = completion
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case didDisappear
        case didEnteredBackground
        case didEnterForeground
        case startPhoneVerfication(phone: String)
        case onStartPhoneVerficationFetched(TaskResult<StartPhoneVerification>)
        case restartPhoneVerfication
        case startPollingCheckPhoneVerfication
        case checkPhoneVerfication
        case onCheckPhoneVerficationFetched(TaskResult<PhoneVerification>)
        case startTimerOfRestartingPhoneVerication
        case decrementTimerOfRestartingPhoneVerication
        case fetchPrefillInfo
        case onPrefillInfoFetched(TaskResult<PrefillInfo>)
        case handleError(NabuError?)
        case loadForm(phone: String?, dateOfBirth: Date?)
        case onClose
        case onContinue
        case onDismissError
        case cancelAllTimers
    }

    struct State: Equatable {
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

        enum Mode: Equatable {
            case info
            case verifyingPhone
            case restartingVerificationLoading
            case loading
            case error(UX.Error)
        }
        var title = LocalizedString.title
        var phone: String?
        var dateOfBirth: Date?
        var restartPhoneVerificationTotalTime: TimeInterval = 0
        var restartPhoneVerificationCountdown: TimeInterval = 0

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
                      let phone: String = try? state.form.nodes.answer(id: InputField.phone.rawValue)
                else {
                    return .none
                }
                state.phone = phone
                state.dateOfBirth = try? state.form.nodes.answer(id: InputField.dateOfBirth.rawValue)
                state.mode = .loading
                return Effect(value: .startPhoneVerfication(phone: phone))

            case .startPhoneVerfication(let phone):
                return .task {
                    await .onStartPhoneVerficationFetched(
                        TaskResult {
                            try await phoneVerificationService.startInstantLinkPossession(
                                phone: phone
                            )
                        }
                    )
                }

            case .onStartPhoneVerficationFetched(.success(let startPhoneVerfication)):
                let resendWaitTime: TimeInterval? = startPhoneVerfication.resendWaitTime.map { TimeInterval($0)
                }
                state.restartPhoneVerificationTotalTime = resendWaitTime ?? 2 * 60
                return .merge(
                    Effect(value: .startPollingCheckPhoneVerfication),
                    Effect(value: .startTimerOfRestartingPhoneVerication)
                )

            case .onStartPhoneVerficationFetched(.failure(let error)):
                return Effect(value: .handleError(error as? NabuError))

            case .restartPhoneVerfication:
                guard let phone = state.phone else { return .none }
                state.mode = .restartingVerificationLoading
                return .merge(
                    Effect(value: .cancelAllTimers),
                    Effect(value: .startPhoneVerfication(phone: phone))
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
                switch phoneVerification.isVerified {
                case true:
                    return .merge(
                        Effect(value: .cancelAllTimers),
                        Effect(value: .fetchPrefillInfo)
                    )
                case false:
                    return .none
                }

            case .onCheckPhoneVerficationFetched(.failure(let error)):
                return Effect(value: .handleError(error as? NabuError))

            case .startTimerOfRestartingPhoneVerication:
                state.restartPhoneVerificationCountdown = state.restartPhoneVerificationTotalTime
                state.isRestartPhoneVerificationButtonDisabled = true
                state.restartPhoneVerificationButtonTitle = String(
                    format: LocalizedString.Body.VerifyingPhone.resendSMSInTimeButton,
                    timerFormatter.string(from: state.restartPhoneVerificationCountdown) ?? ""
                )
                return .merge(
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
                    completion(.abandoned)
                }

            case .fetchPrefillInfo:
                state.mode = .loading
                guard let phone = state.phone,
                      let dateOfBirth = state.dateOfBirth else { return .none }
                return .task {
                    await .onPrefillInfoFetched(
                        TaskResult {
                            try await prefillInfoService.getPrefillInfo(
                                phone: phone,
                                dateOfBirth: dateOfBirth
                            )
                        }
                    )
                }

            case .onPrefillInfoFetched(.success(let prefillInfo)):
                var prefillInfo = prefillInfo
                prefillInfo.phone = prefillInfo.phone ?? state.phone
                prefillInfo.dateOfBirth = prefillInfo.dateOfBirth ?? state.dateOfBirth
                return .fireAndForget {
                    completion(.success(prefillInfo: prefillInfo))
                }

            case .onPrefillInfoFetched(.failure(let error)):
                state.mode = .info
                return Effect(value: .handleError(error as? NabuError))

            case .handleError(let error):
                if error?.code == .provePossessionFailed {
                    return .merge(
                        Effect(value: .cancelAllTimers),
                        .fireAndForget {
                            completion(.failure(.provePossessionFailed))
                        }
                    )
                } else {
                    state.mode = .error(UX.Error(error: error))
                    return Effect(value: .cancelAllTimers)
                }

            case .onDismissError:
                state.mode = .info
                return .none

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
            completion: { _ in }
        )
    }
}

final class NoPhoneVerificationService: PhoneVerificationServiceAPI {

    func startInstantLinkPossession(
        phone: String
    ) async throws -> StartPhoneVerification {
        StartPhoneVerification(resendWaitTime: 60)
    }

    func fetchInstantLinkPossessionStatus() async throws -> PhoneVerification {
        .init(isVerified: true)
    }
}
