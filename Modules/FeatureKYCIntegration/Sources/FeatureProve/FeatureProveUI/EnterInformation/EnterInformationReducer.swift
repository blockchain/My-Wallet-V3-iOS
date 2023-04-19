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

private typealias LocalizedString = LocalizationConstants.EnterInformation

struct EnterInformation: ReducerProtocol {

    enum InputField: String {
        case dateOfBirth
    }

    enum VerificationResult: Equatable {
        case success(prefillInfo: PrefillInfo)
        case abandoned
    }

    let app: AppProtocol
    let prefillInfoService: PrefillInfoServiceAPI
    let completion: (VerificationResult) -> Void

    init(
        app: AppProtocol,
        prefillInfoService: PrefillInfoServiceAPI,
        completion: @escaping (VerificationResult) -> Void
    ) {
        self.app = app
        self.prefillInfoService = prefillInfoService
        self.completion = completion
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case fetchPrefillInfo
        case onPrefillInfoFetched(TaskResult<PrefillInfo>)
        case handleError(NabuError?)
        case onClose
        case onContinue
        case onDismissError
    }

    struct State: Equatable {
        var title: String = LocalizedString.title
        var phone: String?
        var dateOfBirth: Date?

        @BindingState var form: Form = .init(
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

        var isLoading: Bool = false
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
                state.form = .init(
                    header: .init(
                        title: LocalizedString.Body.title,
                        description: LocalizedString.Body.subtitle
                    ),
                    nodes: FormQuestion.personalInfoQuestions(dateOfBirth: nil),
                    blocking: true
                )
                return .none

            case .onContinue:
                guard state.isValidForm else {
                    return .none
                }

                return EffectTask(value: .fetchPrefillInfo)

            case .onClose:
                return .fireAndForget {
                    completion(.abandoned)
                }

            case .fetchPrefillInfo:
                state.isLoading = true
                state.dateOfBirth = try? state.form.nodes.answer(id: InputField.dateOfBirth.rawValue)
                guard let phone = state.phone, let dateOfBirth = state.dateOfBirth else {
                    return .none
                }
                return .task {
                    await .onPrefillInfoFetched(
                        TaskResult {
                            try await prefillInfoService.getPrefillInfo(phone: phone, dateOfBirth: dateOfBirth)
                        }
                    )
                }

            case .onPrefillInfoFetched(.failure(let error)):
                state.isLoading = false
                return EffectTask(value: .handleError(error as? NabuError))

            case .onPrefillInfoFetched(.success(let prefillInfo)):
                state.isLoading = false
                var prefillInfo = prefillInfo
                prefillInfo.phone = prefillInfo.phone ?? state.phone
                prefillInfo.dateOfBirth = prefillInfo.dateOfBirth ?? state.dateOfBirth
                return .fireAndForget {
                    completion(.success(prefillInfo: prefillInfo))
                }

            case .handleError(let error):
                state.uxError = UX.Error(error: error)
                return .none

            case .onDismissError:
                state.uxError = nil
                return .none
            }
        }
    }
}

extension FormQuestion {

    fileprivate static func personalInfoQuestions(dateOfBirth: Date?) -> [FormQuestion] {
        [
            FormQuestion(
                id: EnterInformation.InputField.dateOfBirth.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedString.Body.Form.dateOfBirthInputTitle,
                instructions: LocalizedString.Body.Form.dateOfBirthInputHint,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: EnterInformation.InputField.dateOfBirth.rawValue,
                        type: .date,
                        validation: FormAnswer.Validation(
                            rule: .withinRange,
                            metadata: [
                                .maxValue: String(
                                    (Calendar.current.eighteenYearsAgo ?? Date()).timeIntervalSince1970
                                )
                            ]
                        ),
                        text: nil,
                        input: dateOfBirth?.timeIntervalSince1970.description
                    )
                ]
            )
        ]
    }
}

extension Calendar {

    var eighteenYearsAgo: Date? {
        date(byAdding: .year, value: -18, to: Calendar.current.startOfDay(for: Date()))
    }
}

extension EnterInformation {

    static func preview(app: AppProtocol) -> EnterInformation {
        EnterInformation(
            app: app,
            prefillInfoService: NoPrefillInfoService(),
            completion: { _ in }
        )
    }
}

final class NoPrefillInfoService: PrefillInfoServiceAPI {

    func getPrefillInfo(phone: String, dateOfBirth: Date) async throws -> PrefillInfo {
        .init(
            firstName: "First Name",
            lastName: nil,
            addresses: [],
            dateOfBirth: dateOfBirth,
            phone: phone
        )
    }
}
