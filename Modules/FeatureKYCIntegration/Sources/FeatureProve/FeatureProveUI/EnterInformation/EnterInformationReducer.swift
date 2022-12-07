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
        case abandoned
        case failure
        case success(prefillInfo: PrefillInfo)
    }

    let app: AppProtocol
    let prefillInfoService: PrefillInfoServiceAPI
    let dismissFlow: (VerificationResult) -> Void

    init(
        app: AppProtocol,
        prefillInfoService: PrefillInfoServiceAPI,
        dismissFlow: @escaping (VerificationResult) -> Void
    ) {
        self.app = app
        self.prefillInfoService = prefillInfoService
        self.dismissFlow = dismissFlow
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case fetchPrefillInfo
        case onPrefillInfoFetched(TaskResult<PrefillInfo>)
        case finishedWithError(NabuError?)
        case onClose
        case onContinue
        case onDismissError
    }

    struct State: Equatable {
        var title: String = LocalizedString.title
        var phone: String?

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

                return Effect(value: .fetchPrefillInfo)

            case .onClose:
                return .fireAndForget {
                    dismissFlow(.abandoned)
                }

            case .onDismissError:
                return .fireAndForget {
                    dismissFlow(.failure)
                }

            case .fetchPrefillInfo:
                state.isLoading = true
                guard let dateOfBirth: Date = try? state.form.nodes.answer(id: InputField.dateOfBirth.rawValue) else {
                    return .none
                }
                return .task {
                    await .onPrefillInfoFetched(
                        TaskResult {
                            try await prefillInfoService.getPrefillInfo(dateOfBirth: dateOfBirth)
                        }
                    )
                }

            case .onPrefillInfoFetched(.failure(let error)):
                state.isLoading = false
                return Effect(value: .finishedWithError(error as? NabuError))

            case .onPrefillInfoFetched(.success(let prefillInfo)):
                state.isLoading = false
                return .fireAndForget {
                    dismissFlow(.success(prefillInfo: prefillInfo))
                }

            case .finishedWithError(let error):
                state.uxError = UX.Error(error: error)
                return .fireAndForget {
                    dismissFlow(.failure)
                }
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
            dismissFlow: { _ in }
        )
    }
}

final class NoPrefillInfoService: PrefillInfoServiceAPI {

    func getPrefillInfo(dateOfBirth: Date) async throws -> PrefillInfo {
        .init(
            firstName: "First Name",
            lastName: nil,
            addresses: [],
            dateOfBirth: Date(),
            phone: "234"
        )
    }
}
