// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import Combine
import ComposableArchitecture
import FeatureFormDomain
@testable import FeatureKYCDomain
@testable import FeatureKYCUI
import Localization
import ToolKit
import XCTest

@MainActor final class PersonalInfoReducerTests: XCTestCase {

    private struct RecordedInvocations {
        var onClose: Int = 0
        var onComplete: Int = 0
        var submitForm: Int = 0
    }

    private struct StubbedResults {
        var loadForm: Result<[FormQuestion], KYCFlowError> = .failure(.invalidForm)
        var submitForm: Result<Void, KYCFlowError> = .success(())
    }

    private var testStore: TestStore<
        PersonalInfo.State,
        PersonalInfo.Action
    >!

    private var testScheduler: TestSchedulerOf<DispatchQueue>!

    private var recordedInvocations = RecordedInvocations()
    private var stubbedResults = StubbedResults()

    override func setUpWithError() throws {
        try super.setUpWithError()
        testScheduler = DispatchQueue.test
        let loadForm: () -> AnyPublisher<[FormQuestion], KYCFlowError> = { [weak self] in
            guard let self else { return .empty() }
            switch stubbedResults.loadForm {
            case .success(let result):
                return .just(result)
            case .failure(let error):
                return .failure(error)
            }
        }
        let submitForm: (Form) -> AnyPublisher<Void, KYCFlowError> = { [weak self] _ in
            guard let self else { return .empty() }
            recordedInvocations.submitForm += 1
            switch stubbedResults.submitForm {
            case .success(let result):
                return .just(result)
            case .failure(let error):
                return .failure(error)
            }
        }
        testStore = TestStore(
            initialState: PersonalInfo.State(),
            reducer: {
                PersonalInfo.PersonalInfoReducer(
                    onClose: { [weak self] in
                        self?.recordedInvocations.onClose += 1
                    },
                    onComplete: { [weak self] in
                        self?.recordedInvocations.onComplete += 1
                    },
                    loadForm: loadForm,
                    submitForm: submitForm,
                    analyticsRecorder: MockAnalyticsRecorder(),
                    mainQueue: testScheduler.eraseToAnyScheduler()
                )
            }
        )
    }

    override func tearDownWithError() throws {
        testStore = nil
        testScheduler = nil
        try super.tearDownWithError()
    }

    func test_loadsForm_success() async throws {
        let expectedQuestions = FormQuestion.personalInfoQuestions(firstName: nil, lastName: nil, dateOfBirth: nil)
        stubbedResults.loadForm = .success(expectedQuestions)
        await testStore.send(.loadForm)
        await testScheduler.advance()
        await testStore.receive(.formDidLoad(.success(expectedQuestions))) {
            $0.form = .init(
                header: .init(
                    title: LocalizationConstants.NewKYC.Steps.PersonalInfo.title,
                    description: LocalizationConstants.NewKYC.Steps.PersonalInfo.message
                ),
                nodes: expectedQuestions,
                blocking: true
            )
        }
    }

    func test_loadsForm_failure() async throws {
        await testStore.send(.loadForm)
        await testScheduler.advance()
        await testStore.receive(.formDidLoad(.failure(.invalidForm)))
    }

    func test_submitForm_emptyForm() async throws {
        await testStore.send(.submit)
        XCTAssertEqual(recordedInvocations.submitForm, 0)
    }

    func test_submitsForm_filledForm_success() async throws {
        let newForm: Form = .init(
            nodes: FormQuestion.personalInfoQuestions(
                firstName: "Johnny",
                lastName: "Appleseed",
                dateOfBirth: Calendar.current.eighteenYearsAgo
            )
        )
        await testStore.send(.binding(.set(\.$form, newForm))) {
            $0.form = newForm
        }
        await testStore.send(.submit) {
            $0.formSubmissionState = .loading
        }
        XCTAssertEqual(recordedInvocations.submitForm, 1)
        await testScheduler.advance()
        await testStore.receive(.submissionResultReceived(.success(Empty()))) {
            $0.formSubmissionState = .success(Empty())
        }
        XCTAssertEqual(recordedInvocations.onComplete, 1)
    }

    func test_submitsForm_filledForm_failure() async throws {
        let newForm: Form = .init(
            nodes: FormQuestion.personalInfoQuestions(
                firstName: "Johnny",
                lastName: "Appleseed",
                dateOfBirth: Calendar.current.eighteenYearsAgo
            )
        )
        await testStore.send(.binding(.set(\.$form, newForm))) {
            $0.form = newForm
        }
        stubbedResults.submitForm = .failure(.invalidForm)
        await testStore.send(.submit) {
            $0.formSubmissionState = .loading
        }
        XCTAssertEqual(recordedInvocations.submitForm, 1)
        await testScheduler.advance()
        await testStore.receive(.submissionResultReceived(.failure(.invalidForm))) {
            $0.formSubmissionState = .failure(
                FailureState<PersonalInfo.Action>.init(
                    title: "Something went wrong",
                    message: "invalidForm",
                    buttons: [
                        .cancel(title: "Cancel", action: .dismissSubmissionFailureAlert),
                        .primary(title: "Try again", action: .submit)
                    ]
                )
            )
        }
        XCTAssertEqual(recordedInvocations.onComplete, 0)
        await testStore.send(.dismissSubmissionFailureAlert) {
            $0.formSubmissionState = .idle
        }
    }

    func test_close() async throws {
        await testStore.send(.close)
        XCTAssertEqual(recordedInvocations.onClose, 1)
    }
}
