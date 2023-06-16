// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import FeatureFormDomain
import FeatureKYCDomain
import Foundation
import Localization
import ToolKit

private typealias LocalizedErrorStrings = LocalizationConstants.NewKYC.GenericError
private typealias LocalizedStrings = LocalizationConstants.NewKYC.Steps.PersonalInfo

enum PersonalInfo {

    enum InputField: String {
        case firstName
        case lastName
        case dateOfBirth
    }

    struct State: Equatable {
        @BindingState var form: Form = .init(
            header: .init(
                title: LocalizedStrings.title,
                description: LocalizedStrings.message
            ),
            nodes: [],
            blocking: true
        )
        var formSubmissionState: LoadingState<Empty, FailureState<Action>> = .idle

        var isValidForm: Bool {
            guard !form.nodes.isEmpty else {
                return false
            }
            return form.nodes.isValidForm
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case close
        case loadForm
        case formDidLoad(Result<[FormQuestion], KYCFlowError>)
        case submit
        case submissionResultReceived(Result<Empty, KYCFlowError>)
        case dismissSubmissionFailureAlert
        case onViewAppear
    }

    struct Environment {
        let onClose: () -> Void
        let onComplete: () -> Void
        let loadForm: () -> AnyPublisher<[FormQuestion], KYCFlowError>
        let submitForm: ([FormQuestion]) -> AnyPublisher<Void, KYCFlowError>
        let analyticsRecorder: AnalyticsEventRecorderAPI // TODO: use me
        let mainQueue: AnySchedulerOf<DispatchQueue>
    }

    static let reducer: Reducer<State, Action, Environment> = Reducer { state, action, environment in
        switch action {
        case .binding:
            return .none

        case .close:
            return .fireAndForget(environment.onClose)

        case .loadForm:
            return environment.loadForm()
                .catchToEffect()
                .map(Action.formDidLoad)
                .receive(on: environment.mainQueue)
                .eraseToEffect()

        case .formDidLoad(let result):
            switch result {
            case .success(let questions):
                state.form = .init(
                    header: .init(
                        title: LocalizedStrings.title,
                        description: LocalizedStrings.message
                    ),
                    nodes: questions,
                    blocking: true
                )
            case .failure(let error):
                // This should never fail at the moment
                print(error)
            }
            return .none

        case .submit:
            guard state.isValidForm else {
                return .none
            }
            state.formSubmissionState = .loading
            return environment.submitForm(state.form.nodes)
                .map(Empty.init)
                .catchToEffect()
                .map(Action.submissionResultReceived)
                .receive(on: environment.mainQueue)
                .eraseToEffect()

        case .submissionResultReceived(let result):
            switch result {
            case .success:
                state.formSubmissionState = .success(Empty())
                return .fireAndForget(environment.onComplete)

            case .failure(let error):
                state.formSubmissionState = .failure(
                    FailureState(
                        title: LocalizedErrorStrings.title,
                        message: String(describing: error),
                        buttons: [
                            .cancel(
                                title: LocalizedErrorStrings.cancelButtonTitle,
                                action: .dismissSubmissionFailureAlert
                            ),
                            .primary(
                                title: LocalizedErrorStrings.retryButtonTitle,
                                action: .submit
                            )
                        ]
                    )
                )
                return .none
            }

        case .dismissSubmissionFailureAlert:
            state.formSubmissionState = .idle
            return .none
        case .onViewAppear:
            guard state.form.nodes.isEmpty else {
                return .none
            }
            return EffectTask(value: .loadForm)
        }
    }
    .binding()
}

extension Store where State == PersonalInfo.State, Action == PersonalInfo.Action {

    static let emptyPreview = Store(
        initialState: PersonalInfo.State(),
        reducer: PersonalInfo.reducer,
        environment: PersonalInfo.Environment(
            onClose: {},
            onComplete: {},
            loadForm: {
                .just(
                    FormQuestion.personalInfoQuestions(
                        firstName: nil,
                        lastName: nil,
                        dateOfBirth: nil
                    )
                )
            },
            submitForm: { _ in .empty() },
            analyticsRecorder: NoOpAnalyticsRecorder(),
            mainQueue: .main
        )
    )

    static let filledPreview = Store(
        initialState: PersonalInfo.State(),
        reducer: PersonalInfo.reducer,
        environment: PersonalInfo.Environment(
            onClose: {},
            onComplete: {},
            loadForm: {
                .just(
                    FormQuestion.personalInfoQuestions(
                        firstName: "Johnny",
                        lastName: "Appleseed",
                        dateOfBirth: Date(timeIntervalSinceNow: .years(20))
                    )
                )
            },
            submitForm: { _ in .empty() },
            analyticsRecorder: NoOpAnalyticsRecorder(),
            mainQueue: .main
        )
    )
}

extension FormQuestion {

    static func personalInfoQuestions(firstName: String?, lastName: String?, dateOfBirth: Date?) -> [FormQuestion] {
        [
            FormQuestion(
                id: PersonalInfo.InputField.firstName.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedStrings.firstNameQuestionTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                hint: LocalizedStrings.Placeholders.firstname,
                children: [
                    FormAnswer(
                        id: PersonalInfo.InputField.firstName.rawValue,
                        type: .openEnded,
                        input: (firstName?.isEmpty ?? true) ? nil : firstName
                    )
                ]
            ),
            FormQuestion(
                id: PersonalInfo.InputField.lastName.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedStrings.lastNameQuestionTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                hint: LocalizedStrings.Placeholders.surname,
                children: [
                    FormAnswer(
                        id: PersonalInfo.InputField.lastName.rawValue,
                        type: .openEnded,
                        input: lastName
                    )
                ]
            ),
            FormQuestion(
                id: PersonalInfo.InputField.dateOfBirth.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedStrings.dateOfBirthQuestionTitle,
                instructions: LocalizedStrings.dateOfBirthAnswerHint,
                regex: TextRegex.notEmpty.rawValue,
                hint: LocalizedStrings.Placeholders.dob,
                children: [
                    FormAnswer(
                        id: PersonalInfo.InputField.dateOfBirth.rawValue,
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
