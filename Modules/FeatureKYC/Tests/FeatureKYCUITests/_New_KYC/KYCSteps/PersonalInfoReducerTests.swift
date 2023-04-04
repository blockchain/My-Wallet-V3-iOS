// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import Combine
import ComposableArchitecture
import FeatureFormDomain
@testable import FeatureKYCDomain
@testable import FeatureKYCUI
import ToolKit
import XCTest

final class PersonalInfoReducerTests: XCTestCase {

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
        PersonalInfo.Action,
        PersonalInfo.State,
        PersonalInfo.Action,
        PersonalInfo.Environment
    >!

    private var testScheduler: TestSchedulerOf<DispatchQueue>!

    private var recordedInvocations = RecordedInvocations()
    private var stubbedResults = StubbedResults()

    override func setUpWithError() throws {
        try super.setUpWithError()
        testScheduler = DispatchQueue.test
        testStore = TestStore(
            initialState: PersonalInfo.State(),
            reducer: PersonalInfo.reducer,
            environment: PersonalInfo.Environment(
                onClose: { [weak self] in
                    self?.recordedInvocations.onClose += 1
                },
                onComplete: { [weak self] in
                    self?.recordedInvocations.onComplete += 1
                },
                loadForm: { [weak self] in
                    guard let self else { return .empty() }
                    switch stubbedResults.loadForm {
                    case .success(let result):
                        return .just(result)
                    case .failure(let error):
                        return .failure(error)
                    }
                },
                submitForm: { [weak self] _ in
                    guard let self else { return .empty() }
                    recordedInvocations.submitForm += 1
                    switch stubbedResults.submitForm {
                    case .success(let result):
                        return .just(result)
                    case .failure(let error):
                        return .failure(error)
                    }
                },
                analyticsRecorder: MockAnalyticsRecorder(),
                mainQueue: testScheduler.eraseToAnyScheduler()
            )
        )
    }

    override func tearDownWithError() throws {
        testStore = nil
        testScheduler = nil
        try super.tearDownWithError()
    }

    func test_loadsForm_success() throws {
        let expectedQuestions = FormQuestion.personalInfoQuestions(firstName: nil, lastName: nil, dateOfBirth: nil)
        stubbedResults.loadForm = .success(expectedQuestions)
        testStore.send(.loadForm)
        testScheduler.advance()
        testStore.receive(.formDidLoad(.success(expectedQuestions))) {
            $0.form.nodes = expectedQuestions
        }
    }

    func test_loadsForm_failure() throws {
        testStore.send(.loadForm)
        testScheduler.advance()
        testStore.receive(.formDidLoad(.failure(.invalidForm)))
    }

    func test_submitForm_emptyForm() throws {
        testStore.send(.submit)
        XCTAssertEqual(recordedInvocations.submitForm, 0)
    }

    func test_submitsForm_filledForm_success() throws {
        let newForm: Form = .init(
            nodes: FormQuestion.personalInfoQuestions(
                firstName: "Johnny",
                lastName: "Appleseed",
                dateOfBirth: Calendar.current.eighteenYearsAgo
            )
        )
        testStore.send(.binding(.set(\.$form, newForm))) {
            $0.form = newForm
        }
        testStore.send(.submit) {
            $0.formSubmissionState = .loading
        }
        XCTAssertEqual(recordedInvocations.submitForm, 1)
        testScheduler.advance()
        testStore.receive(.submissionResultReceived(.success(Empty()))) {
            $0.formSubmissionState = .success(Empty())
        }
        XCTAssertEqual(recordedInvocations.onComplete, 1)
    }

    func test_submitsForm_filledForm_failure() throws {
        let newForm: Form = .init(
            nodes: FormQuestion.personalInfoQuestions(
                firstName: "Johnny",
                lastName: "Appleseed",
                dateOfBirth: Calendar.current.eighteenYearsAgo
            )
        )
        testStore.send(.binding(.set(\.$form, newForm))) {
            $0.form = newForm
        }
        stubbedResults.submitForm = .failure(.invalidForm)
        testStore.send(.submit) {
            $0.formSubmissionState = .loading
        }
        XCTAssertEqual(recordedInvocations.submitForm, 1)
        testScheduler.advance()
        testStore.receive(.submissionResultReceived(.failure(.invalidForm))) {
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
        testStore.send(.dismissSubmissionFailureAlert) {
            $0.formSubmissionState = .idle
        }
    }

    func test_close() throws {
        testStore.send(.close)
        XCTAssertEqual(recordedInvocations.onClose, 1)
    }
}
